#define CHARS_PER_LINE 5
#define FONT_SIZE "5pt"
#define FONT_COLOR "#09f"
#define FONT_STYLE "Small Fonts"
#define MAX_TIMER 9000

#define PRESET_SHORT 1200
#define PRESET_MEDIUM 1800
#define PRESET_LONG 3000



///////////////////////////////////////////////////////////////////////////////////////////////
// Brig Door control displays.
//  Description: This is a controls the timer for the brig doors, displays the timer on itself and
//               has a popup window when used, allowing to set the timer.
//  Code Notes: Combination of old brigdoor.dm code from rev4407 and the status_display.dm code
//  Date: 01/September/2010
//  Programmer: Veryinky
/////////////////////////////////////////////////////////////////////////////////////////////////
/obj/machinery/door_timer
	name = "door timer"
	icon = 'icons/obj/status_display.dmi'
	icon_state = "frame"
	desc = "A remote control for a door."
	req_access = list(ACCESS_SECURITY)
	density = FALSE
	var/id = null // id of linked machinery/lockers

	var/activation_time = 0
	var/timer_duration = 0

	var/timing = FALSE		// boolean, true/1 timer is on, false/0 means it's not timing
	var/list/obj/machinery/targets = list()
	var/obj/item/radio/Radio //needed to send messages to sec radio

	maptext_height = 26
	maptext_width = 32
	maptext_y = -1

/obj/machinery/door_timer/Initialize()
	. = ..()

	Radio = new/obj/item/radio(src)
	Radio.listening = 0

/obj/machinery/door_timer/Initialize()
	. = ..()
	if(id != null)
		for(var/obj/machinery/door/window/brigdoor/M in urange(20, src))
			if (M.id == id)
				targets += M

		for(var/obj/machinery/door/airlock/security/brig/D in urange(20, src))
			if (D.id == id)
				targets += D

		for(var/obj/machinery/flasher/F in urange(20, src))
			if(F.id == id)
				targets += F

		for(var/obj/structure/closet/secure_closet/brig/C in urange(20, src))
			if(C.id == id)
				targets += C

	if(!targets.len)
		obj_break()
	update_appearance()


//Main door timer loop, if it's timing and time is >0 reduce time by 1.
// if it's less than 0, open door, reset timer
// update the door_timer window and the icon
/obj/machinery/door_timer/process(seconds_per_tick)
	if(machine_stat & (NOPOWER|BROKEN))
		return

	if(timing)
		if(world.time - activation_time >= timer_duration)
			timer_end() // open doors, reset timer, clear status screen
		update_appearance()

// open/closedoor checks if door_timer has power, if so it checks if the
// linked door is open/closed (by density) then opens it/closes it.
/obj/machinery/door_timer/proc/timer_start()
	if(machine_stat & (NOPOWER|BROKEN))
		return 0

	activation_time = world.time
	timing = TRUE

	for(var/obj/machinery/door/window/brigdoor/door in targets)
		if(door.density)
			continue
		INVOKE_ASYNC(door, TYPE_PROC_REF(/obj/machinery/door/window/brigdoor, close))

	for(var/obj/machinery/door/airlock/security/brig/airlock in targets)
		if(airlock.density)
			continue
		INVOKE_ASYNC(airlock, TYPE_PROC_REF(/obj/machinery/door/airlock/security/brig, close))

	for(var/obj/structure/closet/secure_closet/brig/C in targets)
		if(C.broken)
			continue
		if(C.opened && !C.close())
			continue
		C.locked = TRUE
		C.update_appearance()
	return 1


/obj/machinery/door_timer/proc/timer_end(forced = FALSE)

	if(machine_stat & (NOPOWER|BROKEN))
		return 0

	if(!forced)
		Radio.set_frequency(FREQ_EMERGENCY)
		Radio.talk_into(src, "Timer has expired. Releasing prisoner.", FREQ_EMERGENCY)

	timing = FALSE
	activation_time = null
	set_timer(0)
	update_appearance()

	for(var/obj/machinery/door/window/brigdoor/door in targets)
		if(!door.density)
			continue
		INVOKE_ASYNC(door, TYPE_PROC_REF(/obj/machinery/door/window/brigdoor, open))

	for(var/obj/machinery/door/airlock/security/brig/airlock in targets)
		if(!airlock.density)
			continue
		INVOKE_ASYNC(airlock, TYPE_PROC_REF(/obj/machinery/door/airlock/security/brig, open))

	for(var/obj/structure/closet/secure_closet/brig/C in targets)
		if(C.broken)
			continue
		if(C.opened)
			continue
		C.locked = FALSE
		C.update_appearance()

	return 1


/obj/machinery/door_timer/proc/time_left(seconds = FALSE)
	. = max(0,timer_duration - (activation_time ? world.time - activation_time : 0))
	if(seconds)
		. /= 10

/obj/machinery/door_timer/proc/set_timer(value)
	var/new_time = clamp(value,0,MAX_TIMER)
	. = new_time == timer_duration //return 1 on no change
	timer_duration = new_time

/obj/machinery/door_timer/ui_interact(mob/user, datum/tgui/ui)
	ui = SStgui.try_update_ui(user, src, ui)
	if(!ui)
		ui = new(user, src, "BrigTimer", name)
		ui.open()

//icon update function
// if NOPOWER, display blank
// if BROKEN, display blue screen of death icon AI uses
// if timing=true, run update display function
/obj/machinery/door_timer/update_icon()
	. = ..()
	if(machine_stat & (NOPOWER))
		return

	if(machine_stat & (BROKEN))
		set_picture("ai_bsod")
		return

	if(timing)
		var/disp1 = id
		var/time_left = time_left(seconds = TRUE)
		var/disp2 = "[add_leading(num2text((time_left / 60) % 60), 2, "0")]:[add_leading(num2text(time_left % 60), 2, "0")]"
		if(length(disp2) > CHARS_PER_LINE)
			disp2 = "Error"
		update_display(disp1, disp2)
	else
		if(maptext)
			maptext = ""
	return


// Adds an icon in case the screen is broken/off, stolen from status_display.dm
/obj/machinery/door_timer/proc/set_picture(state)
	if(maptext)
		maptext = ""
	cut_overlays()
	add_overlay(mutable_appearance('icons/obj/status_display.dmi', state))


//Checks to see if there's 1 line or 2, adds text-icons-numbers/letters over display
// Stolen from status_display
/obj/machinery/door_timer/proc/update_display(line1, line2)
	line1 = uppertext(line1)
	line2 = uppertext(line2)
	var/new_text = {"<div style="font-size:[FONT_SIZE];color:[FONT_COLOR];font:'[FONT_STYLE]';text-align:center;" valign="top">[line1]<br>[line2]</div>"}
	if(maptext != new_text)
		maptext = new_text

/obj/machinery/door_timer/ui_data()
	var/list/data = list()
	var/time_left = time_left(seconds = TRUE)
	data["seconds"] = round(time_left % 60)
	data["minutes"] = round((time_left - data["seconds"]) / 60)
	data["timing"] = timing
	data["flash_charging"] = FALSE
	for(var/obj/machinery/flasher/F in targets)
		if(F.last_flash && (F.last_flash + 150) > world.time)
			data["flash_charging"] = TRUE
			break
	return data


/obj/machinery/door_timer/ui_act(action, params)
	. = ..()
	if(.)
		return

	. = TRUE

	if(!allowed(usr))
		to_chat(usr, span_warning("Access denied."))
		return FALSE

	switch(action)
		if("time")
			var/value = text2num(params["adjust"])
			if(value)
				. = set_timer(time_left()+value)
		if("start")
			timer_start()
		if("stop")
			timer_end(forced = TRUE)
		if("flash")
			for(var/obj/machinery/flasher/F in targets)
				F.flash()
		if("preset")
			var/preset = params["preset"]
			var/preset_time = time_left()
			switch(preset)
				if("short")
					preset_time = PRESET_SHORT
				if("medium")
					preset_time = PRESET_MEDIUM
				if("long")
					preset_time = PRESET_LONG
			. = set_timer(preset_time)
			if(timing)
				activation_time = world.time
		else
			. = FALSE


#undef PRESET_SHORT
#undef PRESET_MEDIUM
#undef PRESET_LONG

#undef MAX_TIMER
#undef FONT_SIZE
#undef FONT_COLOR
#undef FONT_STYLE
#undef CHARS_PER_LINE
