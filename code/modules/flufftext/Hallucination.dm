#define HAL_LINES_FILE "hallucination.json"

GLOBAL_LIST_INIT(hallucination_list, list(
	/datum/hallucination/chat = 90,
	/datum/hallucination/message = 50,
	/datum/hallucination/sounds = 40,
	/datum/hallucination/battle = 18,
	/datum/hallucination/hudscrew = 15,
	/datum/hallucination/stray_bullet = 15,
	/datum/hallucination/dangerflash = 12,
	/datum/hallucination/fake_alert = 12,
	/datum/hallucination/weird_sounds = 10,
	/datum/hallucination/items_other = 7,
	/datum/hallucination/husks = 7,
	/datum/hallucination/stationmessage = 5,
	/datum/hallucination/fake_flood = 5,
	/datum/hallucination/bolts = 5,
	/datum/hallucination/delusion = 5,
	/datum/hallucination/self_delusion = 4,
	/datum/hallucination/items = 4,
	/datum/hallucination/shock = 3,
	/datum/hallucination/death = 1,
	/datum/hallucination/fire = 1,
	/datum/hallucination/oh_yeah = 1
	))


/mob/living/carbon/proc/handle_hallucinations()
	if(!hallucination)
		return

	hallucination = max(hallucination - 1, 0)

	if(world.time < next_hallucination)
		return

	var/halpick = pick_weight(GLOB.hallucination_list)
	new halpick(src, FALSE)

	next_hallucination = world.time + rand(100, 600)

/mob/living/carbon/proc/set_screwyhud(hud_type)
	if(HAS_TRAIT(src, TRAIT_ANALGESIA))
		hud_type = SCREWYHUD_HEALTHY
	hal_screwyhud = hud_type
	update_health_hud()

/datum/hallucination
	var/natural = TRUE
	var/mob/living/carbon/target
	var/feedback_details //extra info for investigate

/datum/hallucination/New(mob/living/carbon/C, forced = TRUE)
	set waitfor = FALSE
	target = C
	natural = !forced

/datum/hallucination/proc/wake_and_restore()
	target.set_screwyhud(SCREWYHUD_NONE)
	target.set_sleeping(0)

/datum/hallucination/Destroy()
	target.investigate_log("was afflicted with a hallucination of type [type] by [natural?"hallucination status":"an external source"]. [feedback_details]", INVESTIGATE_HALLUCINATIONS)
	target = null
	return ..()

//Returns a random turf in a ring around the target mob, useful for sound hallucinations
/datum/hallucination/proc/random_far_turf()
	var/x_based = prob(50)
	var/first_offset = pick(-8,-7,-6,-5,5,6,7,8)
	var/second_offset = rand(-8,8)
	var/x_off
	var/y_off
	if(x_based)
		x_off = first_offset
		y_off = second_offset
	else
		y_off = first_offset
		x_off = second_offset
	var/turf/T = locate(target.x + x_off, target.y + y_off, target.z)
	return T

/obj/effect/hallucination
	invisibility = INVISIBILITY_OBSERVER
	anchored = TRUE
	var/mob/living/carbon/target = null

/obj/effect/hallucination/simple
	var/image_icon = 'icons/mob/alien.dmi'
	var/image_state = "alienh_pounce"
	var/px = 0
	var/py = 0
	var/col_mod = null
	var/image/current_image = null
	var/image_layer = MOB_LAYER
	var/active = TRUE //qdelery

/obj/effect/hallucination/singularity_pull()
	return

/obj/effect/hallucination/singularity_act()
	return

/obj/effect/hallucination/simple/Initialize(mapload, mob/living/carbon/T)
	. = ..()
	if(!T)
		stack_trace("A hallucination was created with no target")
		return INITIALIZE_HINT_QDEL
	target = T
	current_image = GetImage()
	if(target.client)
		target.client.images |= current_image

/obj/effect/hallucination/simple/proc/GetImage()
	var/image/I = image(image_icon,src,image_state,image_layer,dir=src.dir)
	I.pixel_x = px
	I.pixel_y = py
	if(col_mod)
		I.color = col_mod
	return I

/obj/effect/hallucination/simple/proc/Show(update=1)
	if(active)
		if(target.client)
			target.client.images.Remove(current_image)
		if(update)
			current_image = GetImage()
		if(target.client)
			target.client.images |= current_image

/obj/effect/hallucination/simple/update_icon(updates=ALL, new_state,new_icon,new_px=0,new_py=0)
	image_state = new_state
	if(new_icon)
		image_icon = new_icon
	else
		image_icon = initial(image_icon)
	px = new_px
	py = new_py
	. = ..()
	Show()

/obj/effect/hallucination/simple/Moved(atom/OldLoc, Dir)
	. = ..()
	if(!loc)
		return
	Show()

/obj/effect/hallucination/simple/Destroy()
	if(target.client)
		target.client.images.Remove(current_image)
	active = FALSE
	return ..()

#define FAKE_FLOOD_EXPAND_TIME 20
#define FAKE_FLOOD_MAX_RADIUS 10

/obj/effect/plasma_image_holder
	icon_state = "nothing"
	anchored = TRUE
	layer = FLY_LAYER
	plane = GAME_PLANE
	mouse_opacity = MOUSE_OPACITY_TRANSPARENT

/datum/hallucination/fake_flood
	//Plasma starts flooding from the nearby vent
	var/turf/center
	var/list/flood_images = list()
	var/list/flood_image_holders = list()
	var/list/turf/flood_turfs = list()
	var/image_icon = 'icons/effects/atmospherics.dmi'
	var/image_state = "plasma"
	var/radius = 0
	var/next_expand = 0

/datum/hallucination/fake_flood/New(mob/living/carbon/C, forced = TRUE)
	set waitfor = FALSE
	..()
	for(var/obj/machinery/atmospherics/components/unary/vent_pump/U in orange(7,target))
		if(!U.welded)
			center = get_turf(U)
			break
	if(!center)
		qdel(src)
		return
	feedback_details += "Vent Coords: [center.x],[center.y],[center.z]"
	var/obj/effect/plasma_image_holder/pih = new(center)
	var/image/plasma_image = image(image_icon, pih, image_state, FLY_LAYER)
	plasma_image.alpha = 50
	plasma_image.plane = GAME_PLANE
	flood_images += plasma_image
	flood_image_holders += pih
	flood_turfs += center
	if(target.client)
		target.client.images |= flood_images
	next_expand = world.time + FAKE_FLOOD_EXPAND_TIME
	START_PROCESSING(SSobj, src)

/datum/hallucination/fake_flood/process(seconds_per_tick)
	if(next_expand <= world.time)
		radius++
		if(radius > FAKE_FLOOD_MAX_RADIUS)
			qdel(src)
			return
		Expand()
		if((get_turf(target) in flood_turfs) && !target.internal)
			new /datum/hallucination/fake_alert(target, TRUE, "too_much_tox")
		next_expand = world.time + FAKE_FLOOD_EXPAND_TIME

/datum/hallucination/fake_flood/proc/Expand()
	for(var/image/I in flood_images)
		I.alpha = min(I.alpha + 50, 255)
	for(var/turf/FT in flood_turfs)
		for(var/dir in GLOB.cardinals)
			var/turf/T = get_step(FT, dir)
			if((T in flood_turfs) || !FT.CanAtmosPass(T))
				continue
			var/obj/effect/plasma_image_holder/pih = new(T)
			var/image/new_plasma = image(image_icon, pih, image_state, FLY_LAYER)
			new_plasma.alpha = 50
			new_plasma.plane = GAME_PLANE
			flood_images += new_plasma
			flood_image_holders += pih
			flood_turfs += T
	if(target.client)
		target.client.images |= flood_images

/datum/hallucination/fake_flood/Destroy()
	STOP_PROCESSING(SSobj, src)
	qdel(flood_turfs)
	flood_turfs = list()
	if(target.client)
		target.client.images.Remove(flood_images)
	qdel(flood_images)
	flood_images = list()
	qdel(flood_image_holders)
	flood_image_holders = list()
	return ..()

/obj/effect/hallucination/simple/xeno
	image_icon = 'icons/mob/alien.dmi'
	image_state = "alienh_pounce"

/obj/effect/hallucination/simple/xeno/Initialize(mapload, mob/living/carbon/T)
	. = ..()
	name = "alien hunter ([rand(1, 1000)])"

/obj/effect/hallucination/simple/xeno/throw_impact(atom/hit_atom, datum/thrownthing/throwingdatum)
	update_icon("alienh_pounce")
	if(hit_atom == target && target.stat!=DEAD)
		target.Paralyze(100)
		target.visible_message(span_danger("[target] flails around wildly."),span_userdanger("[name] pounces on you!"))

/datum/hallucination/xeno_attack
	//Xeno crawls from nearby vent,jumps at you, and goes back in
	var/obj/machinery/atmospherics/components/unary/vent_pump/pump = null
	var/obj/effect/hallucination/simple/xeno/xeno = null

/datum/hallucination/xeno_attack/New(mob/living/carbon/C, forced = TRUE)
	set waitfor = FALSE
	..()
	for(var/obj/machinery/atmospherics/components/unary/vent_pump/U in orange(7,target))
		if(!U.welded)
			pump = U
			break
	if(pump)
		feedback_details += "Vent Coords: [pump.x],[pump.y],[pump.z]"
		xeno = new(pump.loc,target)
		sleep(10)
		xeno.update_icon("alienh_leap",'icons/mob/alienleap.dmi',-32,-32)
		xeno.throw_at(target,7,1, xeno, FALSE, TRUE)
		sleep(10)
		xeno.update_icon("alienh_leap",'icons/mob/alienleap.dmi',-32,-32)
		xeno.throw_at(pump,7,1, xeno, FALSE, TRUE)
		sleep(10)
		var/xeno_name = xeno.name
		to_chat(target, span_notice("[xeno_name] begins climbing into the ventilation system..."))
		sleep(30)
		qdel(xeno)
		to_chat(target, span_notice("[xeno_name] scrambles into the ventilation ducts!"))
	qdel(src)

/obj/effect/hallucination/simple/bubblegum
	name = "Bubblegum"
	image_icon = 'icons/mob/lavaland/96x96megafauna.dmi'
	image_state = "bubblegum"
	px = -32

/datum/hallucination/oh_yeah
	var/obj/effect/hallucination/simple/bubblegum/bubblegum
	var/image/fakebroken
	var/image/fakerune

/datum/hallucination/oh_yeah/New(mob/living/carbon/C, forced = TRUE)
	set waitfor = FALSE
	. = ..()
	var/turf/closed/wall/wall
	for(var/turf/closed/wall/W in range(7,target))
		wall = W
		break
	if(!wall)
		return INITIALIZE_HINT_QDEL
	feedback_details += "Source: [wall.x],[wall.y],[wall.z]"

	fakebroken = image('icons/turf/floors.dmi', wall, "plating", layer = TURF_LAYER)
	var/turf/landing = get_turf(target)
	var/turf/landing_image_turf = get_step(landing, SOUTHWEST) //the icon is 3x3
	fakerune = image('icons/effects/96x96.dmi', landing_image_turf, "landing", layer = ABOVE_OPEN_TURF_LAYER)
	fakebroken.override = TRUE
	if(target.client)
		target.client.images |= fakebroken
		target.client.images |= fakerune
	target.playsound_local(wall,'sound/effects/meteorimpact.ogg', 150, 1)
	bubblegum = new(wall, target)
	addtimer(CALLBACK(src, PROC_REF(bubble_attack), landing), 10)

/datum/hallucination/oh_yeah/proc/bubble_attack(turf/landing)
	var/charged = FALSE //only get hit once
	while(get_turf(bubblegum) != landing && target && target.stat != DEAD)
		bubblegum.forceMove(get_step_towards(bubblegum, landing))
		bubblegum.setDir(get_dir(bubblegum, landing))
		target.playsound_local(get_turf(bubblegum), 'sound/effects/meteorimpact.ogg', 150, 1)
		shake_camera(target, 2, 1)
		if(bubblegum.Adjacent(target) && !charged)
			charged = TRUE
			target.Paralyze(80)
			target.adjustStaminaLoss(40)
			step_away(target, bubblegum)
			shake_camera(target, 4, 3)
			target.visible_message(span_warning("[target] jumps backwards, falling on the ground!"),span_userdanger("[bubblegum] slams into you!"))
		sleep(2)
	sleep(30)
	qdel(src)

/datum/hallucination/oh_yeah/Destroy()
	if(target.client)
		target.client.images.Remove(fakebroken)
		target.client.images.Remove(fakerune)
	QDEL_NULL(fakebroken)
	QDEL_NULL(fakerune)
	QDEL_NULL(bubblegum)
	return ..()

/datum/hallucination/battle

/datum/hallucination/battle/New(mob/living/carbon/C, forced = TRUE, battle_type)
	set waitfor = FALSE
	..()
	var/turf/source = random_far_turf()
	if(!battle_type)
		battle_type = pick("laser","disabler","esword","gun","stunprod","harmbaton","bomb")
	feedback_details += "Type: [battle_type]"
	switch(battle_type)
		if("laser")
			var/hits = 0
			for(var/i in 1 to rand(5, 10))
				target.playsound_local(source, 'sound/weapons/laser.ogg', 25, 1)
				if(prob(50))
					addtimer(CALLBACK(target, TYPE_PROC_REF(/mob, playsound_local), source, 'sound/weapons/sear.ogg', 25, 1), rand(5,10))
					hits++
				else
					addtimer(CALLBACK(target, TYPE_PROC_REF(/mob, playsound_local), source, 'sound/weapons/effects/searwall.ogg', 25, 1), rand(5,10))
				sleep(rand(CLICK_CD_RANGE, CLICK_CD_RANGE + 6))
				if(hits >= 4 && prob(70))
					target.playsound_local(source, get_sfx("bodyfall"), 25, 1)
					break
		if("disabler")
			var/hits = 0
			for(var/i in 1 to rand(5, 10))
				target.playsound_local(source, 'sound/weapons/taser2.ogg', 25, 1)
				if(prob(50))
					addtimer(CALLBACK(target, TYPE_PROC_REF(/mob, playsound_local), source, 'sound/weapons/tap.ogg', 25, 1), rand(5,10))
					hits++
				else
					addtimer(CALLBACK(target, TYPE_PROC_REF(/mob, playsound_local), source, 'sound/weapons/effects/searwall.ogg', 25, 1), rand(5,10))
				sleep(rand(CLICK_CD_RANGE, CLICK_CD_RANGE + 6))
				if(hits >= 3 && prob(70))
					target.playsound_local(source, get_sfx("bodyfall"), 25, 1)
					break
		if("esword")
			target.playsound_local(source, 'sound/weapons/saberon.ogg',15, 1)
			for(var/i in 1 to rand(4, 8))
				target.playsound_local(source, 'sound/weapons/blade1.ogg', 50, 1)
				if(i == 4)
					target.playsound_local(source, get_sfx("bodyfall"), 25, 1)
				sleep(rand(CLICK_CD_MELEE, CLICK_CD_MELEE + 6))
			target.playsound_local(source, 'sound/weapons/saberoff.ogg', 15, 1)
		if("gun")
			var/hits = 0
			for(var/i in 1 to rand(3, 6))
				target.playsound_local(source, 'sound/weapons/gun/shotgun/shot.ogg', 25, TRUE)
				if(prob(60))
					addtimer(CALLBACK(target, TYPE_PROC_REF(/mob, playsound_local), source, 'sound/weapons/pierce.ogg', 25, 1), rand(5,10))
					hits++
				else
					addtimer(CALLBACK(target, TYPE_PROC_REF(/mob, playsound_local), source, "ricochet", 25, 1), rand(5,10))
				sleep(rand(CLICK_CD_RANGE, CLICK_CD_RANGE + 6))
				if(hits >= 2 && prob(80))
					target.playsound_local(source, get_sfx("bodyfall"), 25, 1)
					break
		if("stunprod") //Stunprod + cablecuff
			target.playsound_local(source, 'sound/weapons/egloves.ogg', 40, 1)
			target.playsound_local(source, get_sfx("bodyfall"), 25, 1)
			sleep(20)
			target.playsound_local(source, 'sound/weapons/cablecuff.ogg', 15, 1)
		if("harmbaton") //zap n slap
			target.playsound_local(source, 'sound/weapons/egloves.ogg', 40, 1)
			target.playsound_local(source, get_sfx("bodyfall"), 25, 1)
			sleep(20)
			for(var/i in 1 to rand(5, 12))
				target.playsound_local(source, "swing_hit", 50, 1)
				sleep(rand(CLICK_CD_MELEE, CLICK_CD_MELEE + 4))
		if("bomb") // Tick Tock
			for(var/i in 1 to rand(3, 11))
				target.playsound_local(source, 'sound/items/timer.ogg', 25, 0)
				sleep(15)
	qdel(src)

/datum/hallucination/items_other

/datum/hallucination/items_other/New(mob/living/carbon/C, forced = TRUE, item_type)
	set waitfor = FALSE
	..()
	var/item
	if(!item_type)
		item = pick(list("esword","taser","ebow","baton","dual_esword","ttv","flash","armblade"))
	else
		item = item_type
	feedback_details += "Item: [item]"
	var/side
	var/image_file
	var/image/A = null
	var/list/mob_pool = list()

	for(var/mob/living/carbon/human/M in view(7,target))
		if(M != target)
			mob_pool += M
	if(!mob_pool.len)
		return

	var/mob/living/carbon/human/H = pick(mob_pool)
	feedback_details += " Mob: [H.real_name]"

	var/free_hand = H.get_empty_held_index_for_side(LEFT_HANDS)
	if(free_hand)
		side = "left"
	else
		free_hand = H.get_empty_held_index_for_side(RIGHT_HANDS)
		if(free_hand)
			side = "right"

	if(side)
		switch(item)
			if("esword")
				if(side == "right")
					image_file = 'icons/mob/inhands/weapons/swords_righthand.dmi'
				else
					image_file = 'icons/mob/inhands/weapons/swords_lefthand.dmi'
				target.playsound_local(H, 'sound/weapons/saberon.ogg',35,1)
				A = image(image_file,H,"swordred", layer=ABOVE_MOB_LAYER)
			if("dual_esword")
				if(side == "right")
					image_file = 'icons/mob/inhands/weapons/swords_righthand.dmi'
				else
					image_file = 'icons/mob/inhands/weapons/swords_lefthand.dmi'
				target.playsound_local(H, 'sound/weapons/saberon.ogg',35,1)
				A = image(image_file,H,"dualsaberred1", layer=ABOVE_MOB_LAYER)
			if("taser")
				if(side == "right")
					image_file = GUN_RIGHTHAND_ICON
				else
					image_file = GUN_LEFTHAND_ICON
				A = image(image_file,H,"advtaserstun4", layer=ABOVE_MOB_LAYER)
			if("ebow")
				if(side == "right")
					image_file = GUN_RIGHTHAND_ICON
				else
					image_file = GUN_LEFTHAND_ICON
				A = image(image_file,H,"crossbow", layer=ABOVE_MOB_LAYER)
			if("baton")
				if(side == "right")
					image_file = 'icons/mob/inhands/equipment/security_righthand.dmi'
				else
					image_file = 'icons/mob/inhands/equipment/security_lefthand.dmi'
				target.playsound_local(H, "sparks",75,1,-1)
				A = image(image_file,H,"baton", layer=ABOVE_MOB_LAYER)
			if("ttv")
				if(side == "right")
					image_file = 'icons/mob/inhands/weapons/bombs_righthand.dmi'
				else
					image_file = 'icons/mob/inhands/weapons/bombs_lefthand.dmi'
				A = image(image_file,H,"ttv", layer=ABOVE_MOB_LAYER)
			if("flash")
				if(side == "right")
					image_file = 'icons/mob/inhands/equipment/security_righthand.dmi'
				else
					image_file = 'icons/mob/inhands/equipment/security_lefthand.dmi'
				A = image(image_file,H,"flashtool", layer=ABOVE_MOB_LAYER)
			if("armblade")
				if(side == "right")
					image_file = 'icons/mob/inhands/antag/changeling_righthand.dmi'
				else
					image_file = 'icons/mob/inhands/antag/changeling_lefthand.dmi'
				target.playsound_local(H, 'sound/effects/blobattack.ogg',30,1)
				A = image(image_file,H,"arm_blade", layer=ABOVE_MOB_LAYER)
		if(target.client)
			target.client.images |= A
			sleep(rand(150,250))
			if(item == "esword" || item == "dual_esword")
				target.playsound_local(H, 'sound/weapons/saberoff.ogg',35,1)
			if(item == "armblade")
				target.playsound_local(H, 'sound/effects/blobattack.ogg',30,1)
			target.client.images.Remove(A)
	qdel(src)

/datum/hallucination/delusion
	var/list/image/delusions = list()

/datum/hallucination/delusion/New(mob/living/carbon/C, forced, force_kind = null , duration = rand(30,300),skip_nearby = TRUE, custom_icon = null, custom_icon_file = null, custom_name = null)
	set waitfor = FALSE
	. = ..()
	var/image/A = null
	var/kind = force_kind ? force_kind : pick("doe","mi-go","carp","hermit","frontiersman","ramzi")
	feedback_details += "Type: [kind]"
	var/list/nearby
	if(skip_nearby)
		nearby = get_hearers_in_view(7, target)
	for(var/mob/living/carbon/human/H in GLOB.alive_mob_list)
		if(H == target)
			continue
		if(skip_nearby && (H in nearby))
			continue
		switch(kind)
			if("doe")//Doe
				A = image('icons/mob/animal.dmi',H,"deer-doe")
				A.name = "Doe"
			if("carp")//Carp
				A = image('icons/mob/carp.dmi',H,"carp")
				A.name = "Space Carp"
			if("mi-go")//Mi-go
				A = image('icons/mob/animal.dmi',H,"mi-go")
				A.name = "Mi-go"
			if("hermit")//Hermit
				A = image('icons/mob/simple_human.dmi',H,"survivor_gunslinger")
				A.name = "Hermit Soldier"
			if("frontiersman")//Frontiersman
				A = image('icons/mob/simple_human.dmi',H,"frontiersmanrangedminigun")
				A.name = "Frontiersman"
			if("ramzi")//Ramzi
				A = image('icons/mob/simple_human.dmi',H,"ramzi_base")
				A.name = "Ramzi Commando"
			if("custom")
				A = image(custom_icon_file, H, custom_icon)
				A.name = custom_name
		A.override = 1
		if(target.client)
			delusions |= A
			target.client.images |= A
		addtimer(CALLBACK(GLOBAL_PROC, GLOBAL_PROC_REF(qdel), src), duration)

/datum/hallucination/delusion/Destroy()
	for(var/image/I in delusions)
		if(target.client)
			target.client.images.Remove(I)
	return ..()

/datum/hallucination/self_delusion
	var/image/delusion

/datum/hallucination/self_delusion/New(mob/living/carbon/C, forced, force_kind = null , duration = rand(30,300), custom_icon = null, custom_icon_file = null, wabbajack = TRUE) //set wabbajack to false if you want to use another fake source
	set waitfor = FALSE
	..()
	var/image/A = null
	var/kind = force_kind ? force_kind : pick("doe","mi-go","carp","hermit","frontiersman","ramzi","pai","robot")
	feedback_details += "Type: [kind]"
	switch(kind)
		if("doe")//Doe
			A = image('icons/mob/animal.dmi',target,"deer-doe")
		if("carp")//Carp
			A = image('icons/mob/animal.dmi',target,"carp")
		if("mi-go")//Mi-go
			A = image('icons/mob/animal.dmi',target,"mi-go")
		if("hermit")//Hermit
			A = image('icons/mob/simple_human.dmi',target,"survivor_base")
		if("frontiersman")//Frontiersman
			A = image('icons/mob/simple_human.dmi',target,"frontiersmanranged")
		if("ramzi")//Ramzi
			A = image('icons/mob/simple_human.dmi',target,"ramzi_base")
		if("pai")//pAI
			A = image('icons/mob/pai.dmi',target,"repairbot")
			target.playsound_local(target,'sound/effects/pai_boot.ogg', 75, 1)
		if("robot")//Cyborg
			A = image('icons/mob/robots.dmi',target,"robot")
			target.playsound_local(target,'sound/voice/liveagain.ogg', 75, 1)
		if("custom")
			A = image(custom_icon_file, target, custom_icon)
	A.override = 1
	if(target.client)
		if(wabbajack)
			to_chat(target, span_hear("...you look down and notice... you aren't the same as you used to be..."))
		delusion = A
		target.client.images |= A
	addtimer(CALLBACK(GLOBAL_PROC, GLOBAL_PROC_REF(qdel), src), duration)

/datum/hallucination/self_delusion/Destroy()
	if(target.client)
		target.client.images.Remove(delusion)
	return ..()

/datum/hallucination/bolts
	var/list/locks = list()

/datum/hallucination/bolts/New(mob/living/carbon/C, forced, door_number)
	set waitfor = FALSE
	..()
	if(!door_number)
		door_number = rand(0,4) //if 0 bolts all visible doors
	var/count = 0
	feedback_details += "Door amount: [door_number]"
	for(var/obj/machinery/door/airlock/A in range(7, target))
		if(count>door_number && door_number>0)
			break
		if(!A.density)
			continue
		count++
		var/obj/effect/hallucination/fake_door_lock/lock = new(get_turf(A))
		lock.target = target
		lock.airlock = A
		locks += lock
		lock.lock()
		sleep(rand(4,12))
	sleep(100)
	for(var/obj/effect/hallucination/fake_door_lock/lock in locks)
		locks -= lock
		lock.unlock()
		sleep(rand(4,12))
	qdel(src)

/obj/effect/hallucination/fake_door_lock
	layer = CLOSED_DOOR_LAYER + 1 //for Bump priority
	var/image/bolt_light
	var/obj/machinery/door/airlock/airlock

/obj/effect/hallucination/fake_door_lock/proc/lock()
	bolt_light = image(airlock.overlays_file, airlock, "lights_bolts",layer=layer)
	if(target.client)
		target.client.images |= bolt_light
		target.playsound_local(get_turf(airlock), 'sound/machines/boltsdown.ogg',30,0,3)

/obj/effect/hallucination/fake_door_lock/proc/unlock()
	if(target.client)
		target.client.images.Remove(bolt_light)
		target.playsound_local(get_turf(airlock), 'sound/machines/boltsup.ogg',30,0,3)
	qdel(src)

/obj/effect/hallucination/fake_door_lock/CanAllowThrough(atom/movable/mover, border_dir)
	. = ..()
	if(mover == target && airlock.density)
		return FALSE

/datum/hallucination/chat

/datum/hallucination/chat/New(mob/living/carbon/C, forced = TRUE, force_radio, specific_message)
	set waitfor = FALSE
	..()
	var/target_name = target.first_name()
	var/speak_messages = list(
		"[pick_list_replacements(HAL_LINES_FILE, "suspicion")]",\
		"[pick_list_replacements(HAL_LINES_FILE, "weird")]",\
		"[pick_list_replacements(HAL_LINES_FILE, "didyouhearthat")]",\
		"[pick_list_replacements(HAL_LINES_FILE, "doubt")]",\
		"[pick_list_replacements(HAL_LINES_FILE, "aggressive")]",\
		"[pick_list_replacements(HAL_LINES_FILE, "help")]!!",\
		"[pick_list_replacements(HAL_LINES_FILE, "escape")]",\
		"[pick("We think you're","Are you","We know you're","I think you're","I'm almost sure you're","The crew doesn't know yet, but I know you're","I know you're","They think you're","[target.first_name()], are you")] [pick_list_replacements(HAL_LINES_FILE, "accusations")]",\
		"[pick("We need you to","Cap said to","Hey... let's","I need your help to","Are you going to","We are going to")] [pick_list_replacements(HAL_LINES_FILE, "threat")] the [pick_list_replacements(HAL_LINES_FILE, "people")]",\
		"[pick("I think I'm infected, I'm infected with something","I'm infected","NonononoNO, I'm infected")], [pick_list_replacements(HAL_LINES_FILE, "infection_advice")]")

	var/radio_messages = list(
		"[pick("Is","We think","I'm almost sure","Oh fuck... I think","I think")] [pick_list_replacements(HAL_LINES_FILE, "people")] is [pick_list_replacements(HAL_LINES_FILE, "accusations")]",\
		"[pick("We","They","I")] [pick("need to", "gotta", "have to", "should","got told to","got ordered to","are going to")] [pick_list_replacements(HAL_LINES_FILE, "threat")] [pick("[target.first_name()]","[pick_list_replacements(HAL_LINES_FILE, "people")]")]")

	var/mob/living/carbon/person = null
	var/datum/language/understood_language = target.get_random_understood_language()
	for(var/mob/living/carbon/H in view(target))
		if(H == target)
			continue
		if(!person)
			person = H
		else
			if(get_dist(target,H)<get_dist(target,person))
				person = H

	var/atom/movable/virtualspeaker/speaker

	// Get person to affect if radio hallucination
	var/is_radio = !person || force_radio
	if (is_radio)
		var/list/humans = list()
		for(var/mob/living/carbon/human/H in GLOB.alive_mob_list)
			humans += H
		person = pick(humans)
		speaker = new(null, person, target)
		target.playsound_local(src, "sound/effects/radio_chatter.ogg", 20, FALSE)

	// Generate message
	var/spans = list(person.speech_span)
	var/chosen = !specific_message ? capitalize(pick(is_radio ? speak_messages : radio_messages)) : specific_message
	chosen = replacetext(chosen, "%TARGETNAME%", target_name)

	var/end = copytext(chosen, length(chosen)) //Hallucinations are given the same punctuation treatment player messages are given, for that slight bit of extra spook
	if(!(end in list("!",".","?",":","-")))
		chosen += "."

	var/message = target.compose_message(speaker || person, understood_language, chosen, is_radio ? "[FREQ_COMMON]" : null, spans, face_name = TRUE)
	feedback_details += "Type: [is_radio ? "Radio" : "Talk"], Source: [person.real_name], Message: [message]"

	// Display message
	if (!is_radio && !target.client?.prefs.chat_on_map)
		var/image/speech_overlay = image('icons/mob/talk.dmi', person, "default0", layer = ABOVE_MOB_LAYER)
		INVOKE_ASYNC(GLOBAL_PROC, GLOBAL_PROC_REF(flick_overlay_global), speech_overlay, list(target.client), 3 SECONDS)
	if (target.client?.prefs.chat_on_map)
		target.create_chat_message(speaker || person, understood_language, chosen, spans)
	to_chat(target, message)
	qdel(src)

/datum/hallucination/message

/datum/hallucination/message/New(mob/living/carbon/C, forced = TRUE)
	set waitfor = FALSE
	..()
	var/list/mobpool = list()
	var/mob/living/carbon/human/other
	var/close_other = FALSE
	for(var/mob/living/carbon/human/H in oview(target, 7))
		if(get_dist(H, target) <= 1)
			other = H
			close_other = TRUE
			break
		mobpool += H
	if(!other && mobpool.len)
		other = pick(mobpool)

	var/list/message_pool = list()
	if(other)
		if(close_other) //increase the odds
			for(var/i in 1 to 5)
				message_pool.Add(span_warning("You feel a tiny prick!"))
		var/obj/item/storage/equipped_backpack = other.get_item_by_slot(ITEM_SLOT_BACK)
		if(istype(equipped_backpack))
			for(var/i in 1 to 5) //increase the odds
				message_pool.Add("<span class='notice'>[other] puts the [pick(\
					"revolver","energy sword","cryptographic sequencer","power sink","energy bow",\
					"stun baton","flash","syringe gun","circular saw","tank transfer valve",\
					"ritual dagger","spellbook",\
					"pulse rifle","hypospray","ship blueprints",\
					"ship keys","Candor","Commander","credits","handcuffs","you",\
					)] into [equipped_backpack].</span>")

		message_pool.Add("<B>[other]</B> [pick("sneezes","coughs")].")

	message_pool.Add(span_notice("You hear something squeezing through the pipes..."),
		span_warning("You hear something squelching in the ground beneath you..."),
		span_warning("You feel something inside your [pick("arm","leg","back","head")]."),
		span_warning("You feel [pick("angry","empty","dry","woozy")]."),
		span_warning("Your stomach rumbles."),
		span_warning("Your head hurts."),
		span_warning("You hear a faint buzz in your head."),
		span_warning("The edges of your vision go dark."),
		span_warning("You feel your head slowly splitting in two."),
		span_warning("Your fingers feel like they're melting off."),
		span_warning("You can't count how many fingers you have... there are too many."),
		span_warning("You start sinking into the ground beneath you."))
	if(prob(20))
		message_pool.Add(span_warning("Behind you."),\
			span_warning("You hear a faint laughter approaching you."),
			span_warning("Something darts across your vision."),
			span_warning("You hear skittering on the ceiling."),
			span_warning("There's something squirming around inside of you."),
			span_warning("It has found you."),
			span_warning("You hear skittering on the ceiling."),
			span_warning("You see an inhumanly tall silhouette moving in the distance."))
	if(prob(10))
		message_pool.Add("[pick_list_replacements(HAL_LINES_FILE, "advice")]")
	var/chosen = pick(message_pool)
	feedback_details += "Message: [chosen]"
	to_chat(target, chosen)
	qdel(src)

/datum/hallucination/sounds

/datum/hallucination/sounds/New(mob/living/carbon/C, forced = TRUE, sound_type)
	set waitfor = FALSE
	..()
	var/turf/source = random_far_turf()
	if(!sound_type)
		sound_type = pick("airlock","airlock pry","console","explosion","far explosion","mech","glass","alarm","beepsky","mech","wall decon","door hack","speen") //WS - Ghostspeen
	feedback_details += "Type: [sound_type]"
	//Strange audio
	switch(sound_type)
		if("airlock")
			target.playsound_local(source,'sound/machines/airlocks/standard/open.ogg', 30, 1)
		if("airlock pry")
			target.playsound_local(source,'sound/machines/creaking.ogg', 100, 1)
			sleep(50)
			target.playsound_local(source, 'sound/machines/airlockforced.ogg', 30, 1)
		if("console")
			target.playsound_local(source,'sound/machines/terminal_prompt.ogg', 25, 1)
		if("explosion")
			if(prob(50))
				target.playsound_local(source,'sound/effects/explosion1.ogg', 50, 1)
			else
				target.playsound_local(source, 'sound/effects/explosion2.ogg', 50, 1)
		if("far explosion")
			target.playsound_local(source, 'sound/effects/explosionfar.ogg', 50, 1)
		if("glass")
			target.playsound_local(source, pick('sound/effects/glassbr1.ogg','sound/effects/glassbr2.ogg','sound/effects/glassbr3.ogg'), 50, 1)
		if("alarm")
			target.playsound_local(source, 'sound/machines/alarm.ogg', 100, 0)
		if("beepsky")
			target.playsound_local(source, 'sound/voice/beepsky/freeze.ogg', 35, 0)
		if("mech")
			var/mech_dir = pick(GLOB.cardinals)
			for(var/i in 1 to rand(4,9))
				if(prob(75))
					target.playsound_local(source, 'sound/mecha/mechstep.ogg', 40, 1)
					source = get_step(source, mech_dir)
				else
					target.playsound_local(source, 'sound/mecha/mechturn.ogg', 40, 1)
					mech_dir = pick(GLOB.cardinals)
				sleep(10)
		//Deconstructing a wall
		if("wall decon")
			target.playsound_local(source, 'sound/items/welder.ogg', 50, 1)
			sleep(105)
			target.playsound_local(source, 'sound/items/welder2.ogg', 50, 1)
			sleep(15)
			target.playsound_local(source, 'sound/items/ratchet.ogg', 50, 1)
		//Hacking a door
		if("door hack")
			target.playsound_local(source, 'sound/items/screwdriver.ogg', 50, 1)
			sleep(rand(40,80))
			target.playsound_local(source, 'sound/machines/airlockforced.ogg', 30, 1)
		if("speen") //WS - Ghostspeen
			target.playsound_local(source, 'sound/voice/speen.ogg', 50, 1)
	qdel(src)

/datum/hallucination/weird_sounds

/datum/hallucination/weird_sounds/New(mob/living/carbon/C, forced = TRUE, sound_type)
	set waitfor = FALSE
	..()
	var/turf/source = random_far_turf()
	if(!sound_type)
		sound_type = pick("phone","hallelujah","highlander","laughter","hyperspace","game over","creepy","tesla")
	feedback_details += "Type: [sound_type]"
	//Strange audio
	switch(sound_type)
		if("phone")
			target.playsound_local(source, 'sound/weapons/ring.ogg', 15)
			sleep(25)
			target.playsound_local(source, 'sound/weapons/ring.ogg', 15)
			sleep(25)
			target.playsound_local(source, 'sound/weapons/ring.ogg', 15)
			sleep(25)
			target.playsound_local(source, 'sound/weapons/ring.ogg', 15)
		if("hyperspace")
			target.playsound_local(null, 'sound/runtime/hyperspace/hyperspace_begin.ogg', 50)
		if("hallelujah")
			target.playsound_local(source, 'sound/effects/pray_chaplain.ogg', 50)
		if("highlander")
			target.playsound_local(null, 'sound/misc/highlander.ogg', 50)
		if("game over")
			target.playsound_local(source, 'sound/misc/compiler-failure.ogg', 50)
		if("laughter")
			if(prob(50))
				target.playsound_local(source, 'sound/voice/human/womanlaugh.ogg', 50, 1)
			else
				target.playsound_local(source, pick('sound/voice/human/manlaugh1.ogg', 'sound/voice/human/manlaugh2.ogg'), 50, 1)
		if("creepy")
		//These sounds are (mostly) taken from Hidden: Source
			target.playsound_local(source, pick(GLOB.creepy_ambience), 50, 1)
		if("tesla") //Tesla loose!
			target.playsound_local(source, 'sound/magic/lightningbolt.ogg', 35, 1)
			sleep(30)
			target.playsound_local(source, 'sound/magic/lightningbolt.ogg', 65, 1)
			sleep(30)
			target.playsound_local(source, 'sound/magic/lightningbolt.ogg', 100, 1)

	qdel(src)

/datum/hallucination/stationmessage

/datum/hallucination/stationmessage/New(mob/living/carbon/C, forced = TRUE, message)
	set waitfor = FALSE
	..()
	if(!message)
		message = pick("blob alert","supermatter")
	feedback_details += "Type: [message]"
	switch(message)
		if("blob alert")
			to_chat(target, "<h1 class='alert'>Biohazard Alert</h1>")
			to_chat(target, "<br><br>[span_alert("Confirmed outbreak of level 5 biohazard aboard the ship. All personnel must contain the outbreak.")]<br><br>")
			SEND_SOUND(target, 'sound/ai/outbreak5.ogg')
		if("supermatter")
			SEND_SOUND(target, 'sound/magic/charge.ogg')
			to_chat(target, span_boldannounce("You feel reality distort for a moment..."))

/datum/hallucination/hudscrew

/datum/hallucination/hudscrew/New(mob/living/carbon/C, forced = TRUE, screwyhud_type)
	set waitfor = FALSE
	..()
	//Screwy HUD
	var/chosen_screwyhud = screwyhud_type
	if(!chosen_screwyhud)
		chosen_screwyhud = pick(SCREWYHUD_CRIT,SCREWYHUD_DEAD,SCREWYHUD_HEALTHY)
	target.set_screwyhud(chosen_screwyhud)
	feedback_details += "Type: [target.hal_screwyhud]"
	sleep(rand(100,250))
	target.set_screwyhud(SCREWYHUD_NONE)
	qdel(src)

/datum/hallucination/fake_alert

/datum/hallucination/fake_alert/New(mob/living/carbon/C, forced = TRUE, specific, duration = 150)
	set waitfor = FALSE
	..()
	var/alert_type = pick("not_enough_oxy","not_enough_tox","not_enough_co2","too_much_oxy","too_much_co2","too_much_tox","newlaw","nutrition","charge","gravity","fire","locked","hacked","temphot","tempcold","pressure")
	if(specific)
		alert_type = specific
	feedback_details += "Type: [alert_type]"
	switch(alert_type)
		if("not_enough_oxy")
			target.throw_alert(alert_type, /atom/movable/screen/alert/not_enough_oxy, override = TRUE)
		if("not_enough_tox")
			target.throw_alert(alert_type, /atom/movable/screen/alert/not_enough_tox, override = TRUE)
		if("not_enough_co2")
			target.throw_alert(alert_type, /atom/movable/screen/alert/not_enough_co2, override = TRUE)
		if("too_much_oxy")
			target.throw_alert(alert_type, /atom/movable/screen/alert/too_much_oxy, override = TRUE)
		if("too_much_co2")
			target.throw_alert(alert_type, /atom/movable/screen/alert/too_much_co2, override = TRUE)
		if("too_much_tox")
			target.throw_alert(alert_type, /atom/movable/screen/alert/too_much_tox, override = TRUE)
		if("nutrition")
			target.throw_alert(alert_type, /atom/movable/screen/alert/starving, override = TRUE)
		if("gravity")
			target.throw_alert(alert_type, /atom/movable/screen/alert/weightless, override = TRUE)
		if("fire")
			target.throw_alert(alert_type, /atom/movable/screen/alert/fire, override = TRUE)
		if("temphot")
			alert_type = "temp"
			target.throw_alert(alert_type, /atom/movable/screen/alert/hot, 3, override = TRUE)
		if("tempcold")
			alert_type = "temp"
			target.throw_alert(alert_type, /atom/movable/screen/alert/cold, 3, override = TRUE)
		if("pressure")
			if(prob(50))
				target.throw_alert(alert_type, /atom/movable/screen/alert/highpressure, 2, override = TRUE)
			else
				target.throw_alert(alert_type, /atom/movable/screen/alert/lowpressure, 2, override = TRUE)
		//BEEP BOOP I AM A ROBOT
		if("newlaw")
			target.throw_alert(alert_type, /atom/movable/screen/alert/newlaw, override = TRUE)
		if("locked")
			target.throw_alert(alert_type, /atom/movable/screen/alert/locked, override = TRUE)
		if("hacked")
			target.throw_alert(alert_type, /atom/movable/screen/alert/hacked, override = TRUE)
		if("charge")
			target.throw_alert(alert_type, /atom/movable/screen/alert/emptycell, override = TRUE)
	sleep(duration)
	target.clear_alert(alert_type, clear_override = TRUE)
	qdel(src)

/datum/hallucination/items

/datum/hallucination/items/New(mob/living/carbon/C, forced = TRUE)
	set waitfor = FALSE
	..()
	//Strange items
	if(!target.halitem)
		target.halitem = new
		var/obj/item/l_hand = target.get_item_for_held_index(1)
		var/obj/item/r_hand = target.get_item_for_held_index(2)
		var/l = ui_hand_position(target.get_held_index_of_item(l_hand))
		var/r = ui_hand_position(target.get_held_index_of_item(r_hand))
		var/list/slots_free = list(l,r)
		if(l_hand)
			slots_free -= l
		if(r_hand)
			slots_free -= r
		if(ishuman(target))
			var/mob/living/carbon/human/H = target
			if(!H.belt)
				slots_free += ui_belt
			if(!H.l_store)
				slots_free += ui_storage1
			if(!H.r_store)
				slots_free += ui_storage2
		if(slots_free.len)
			target.halitem.screen_loc = pick(slots_free)
			target.halitem.layer = ABOVE_HUD_LAYER
			target.halitem.plane = ABOVE_HUD_PLANE
			switch(rand(1,6))
				if(1) //revolver
					target.halitem.icon = 'icons/obj/guns/projectile.dmi'
					target.halitem.icon_state = "revolver"
					target.halitem.name = "Revolver"
				if(2) //c4
					target.halitem.icon = 'icons/obj/grenade.dmi'
					target.halitem.icon_state = "plastic-explosive0"
					target.halitem.name = "C4"
					if(prob(25))
						target.halitem.icon_state = "plasticx40"
				if(3) //sword
					target.halitem.icon = 'icons/obj/weapon/energy.dmi'
					target.halitem.icon_state = "sword0"
					target.halitem.name = "Energy Sword"
				if(4) //stun baton
					target.halitem.icon = 'icons/obj/items.dmi'
					target.halitem.icon_state = "stunbaton"
					target.halitem.name = "Stun Baton"
				if(5) //emag
					target.halitem.icon = 'icons/obj/card.dmi'
					target.halitem.icon_state = "emag"
					target.halitem.name = "Cryptographic Sequencer"
				if(6) //flashbang
					target.halitem.icon = 'icons/obj/grenade.dmi'
					target.halitem.icon_state = "flashbang1"
					target.halitem.name = "Flashbang"
			feedback_details += "Type: [target.halitem.name]"
			if(target.client)
				target.client.screen += target.halitem
			QDEL_IN(target.halitem, rand(150, 350))
	qdel(src)

/datum/hallucination/dangerflash

/datum/hallucination/dangerflash/New(mob/living/carbon/C, forced = TRUE, danger_type)
	set waitfor = FALSE
	..()
	//Flashes of danger
	if(!target.halimage)
		var/list/possible_points = list()
		for(var/turf/open/floor/F in view(target,world.view))
			possible_points += F
		if(possible_points.len)
			var/turf/open/floor/danger_point = pick(possible_points)
			if(!danger_type)
				danger_type = pick("lava","chasm","anomaly")
			switch(danger_type)
				if("lava")
					new /obj/effect/hallucination/danger/lava(danger_point, target)
				if("chasm")
					new /obj/effect/hallucination/danger/chasm(danger_point, target)
				if("anomaly")
					new /obj/effect/hallucination/danger/anomaly(danger_point, target)
	qdel(src)

/obj/effect/hallucination/danger
	var/image/image

/obj/effect/hallucination/danger/proc/show_icon()
	return

/obj/effect/hallucination/danger/proc/clear_icon()
	if(image && target.client)
		target.client.images -= image

/obj/effect/hallucination/danger/Initialize(mapload, _target)
	. = ..()
	target = _target
	show_icon()
	QDEL_IN(src, rand(200, 450))

/obj/effect/hallucination/danger/Destroy()
	clear_icon()
	. = ..()

/obj/effect/hallucination/danger/lava
	name = "lava"


/obj/effect/hallucination/danger/lava/Initialize(mapload, _target)
	. = ..()
	var/static/list/loc_connections = list(
		COMSIG_ATOM_ENTERED = PROC_REF(on_entered),
	)
	AddElement(/datum/element/connect_loc, loc_connections)

/obj/effect/hallucination/danger/lava/show_icon()
	image = image('icons/turf/floors/lava.dmi', src, "lava-0", TURF_LAYER)
	if(target.client)
		target.client.images += image

/obj/effect/hallucination/danger/lava/proc/on_entered(datum/source, atom/movable/AM)
	SIGNAL_HANDLER
	if(AM == target)
		target.adjustStaminaLoss(20)
		new /datum/hallucination/fire(target)

/obj/effect/hallucination/danger/chasm
	name = "chasm"

/obj/effect/hallucination/danger/chasm/Initialize(mapload, _target)
	. = ..()
	var/static/list/loc_connections = list(
		COMSIG_ATOM_ENTERED = PROC_REF(on_entered),
	)
	AddElement(/datum/element/connect_loc, loc_connections)

/obj/effect/hallucination/danger/chasm/show_icon()
	var/turf/target_loc = get_turf(target)
	image = image('icons/turf/floors/chasms.dmi', src, "chasms-[target_loc.smoothing_junction]", TURF_LAYER)
	if(target.client)
		target.client.images += image

/obj/effect/hallucination/danger/chasm/proc/on_entered(datum/source, atom/movable/AM)
	SIGNAL_HANDLER
	if(AM == target)
		if(istype(target, /obj/effect/dummy/phased_mob))
			return
		to_chat(target, span_userdanger("You fall into the chasm!"))
		target.Paralyze(40)
		addtimer(CALLBACK(GLOBAL_PROC, GLOBAL_PROC_REF(to_chat), target, span_notice("It's surprisingly shallow.")), 15)
		QDEL_IN(src, 30)

/obj/effect/hallucination/danger/anomaly
	name = "flux wave anomaly"

/obj/effect/hallucination/danger/anomaly/Initialize()
	. = ..()
	START_PROCESSING(SSobj, src)
	var/static/list/loc_connections = list(
		COMSIG_ATOM_ENTERED = PROC_REF(on_entered),
	)
	AddElement(/datum/element/connect_loc, loc_connections)

/obj/effect/hallucination/danger/anomaly/process(seconds_per_tick)
	if(SPT_PROB(45, seconds_per_tick))
		step(src,pick(GLOB.alldirs))

/obj/effect/hallucination/danger/anomaly/Destroy()
	STOP_PROCESSING(SSobj, src)
	return ..()

/obj/effect/hallucination/danger/anomaly/show_icon()
	image = image('icons/effects/effects.dmi',src,"electricity2",OBJ_LAYER+0.01)
	if(target.client)
		target.client.images += image

/obj/effect/hallucination/danger/anomaly/proc/on_entered(datum/source, atom/movable/AM)
	SIGNAL_HANDLER
	if(AM == target)
		new /datum/hallucination/shock(target)

/datum/hallucination/death

/datum/hallucination/death/New(mob/living/carbon/C, forced = TRUE)
	set waitfor = FALSE
	..()
	target.set_screwyhud(SCREWYHUD_DEAD)
	target.Paralyze(300)
	target.silent += 10
	to_chat(target, span_deadsay("<b>[target.real_name]</b> has died at <b>[get_area_name(target)]</b>."))
	if(prob(50))
		var/mob/fakemob
		var/list/dead_people = list()
		for(var/mob/dead/observer/G in GLOB.player_list)
			dead_people += G
		if(LAZYLEN(dead_people))
			fakemob = pick(dead_people)
		else
			fakemob = target //ever been so lonely you had to haunt yourself?
		if(fakemob)
			sleep(rand(20, 50))
			to_chat(target, span_deadsay("<b>DEAD: [fakemob.name]</b> says, [pick("We've missed you","That whole ship is dying","Heyyyy [target.first_name()]","Come watch this with us [target.first_name()]","I think someone poisoned everyone on that ship")]"))
	sleep(rand(70,90))
	target.set_screwyhud(SCREWYHUD_NONE)
	target.SetParalyzed(0)
	target.silent = FALSE
	qdel(src)

/datum/hallucination/fire
	var/active = TRUE
	var/stage = 0
	var/image/fire_overlay

/datum/hallucination/fire/New(mob/living/carbon/C, forced = TRUE)
	set waitfor = FALSE
	..()
	target.fire_stacks = max(target.fire_stacks, 0.1) //Placebo flammability
	fire_overlay = image('icons/mob/OnFire.dmi', target, "Standing", ABOVE_MOB_LAYER)
	if(target.client)
		target.client.images += fire_overlay
	to_chat(target, span_userdanger("You're set on fire!"))
	target.throw_alert("fire", /atom/movable/screen/alert/fire, override = TRUE)
	sleep(20)
	for(var/i in 1 to 3)
		if(target.fire_stacks <= 0)
			clear_fire()
			return
		stage++
		update_temp()
		sleep(30)
	for(var/i in 1 to rand(5, 10))
		if(target.fire_stacks <= 0)
			clear_fire()
			return
		target.adjustStaminaLoss(15)
		sleep(20)
	clear_fire()

/datum/hallucination/fire/proc/update_temp()
	if(stage <= 0)
		target.clear_alert("temp", clear_override = TRUE)
	else
		target.clear_alert("temp", clear_override = TRUE)
		target.throw_alert("temp", /atom/movable/screen/alert/hot, stage, override = TRUE)

/datum/hallucination/fire/proc/clear_fire()
	if(!active)
		return
	active = FALSE
	target.clear_alert("fire", clear_override = TRUE)
	if(target.client)
		target.client.images -= fire_overlay
	QDEL_NULL(fire_overlay)
	while(stage > 0)
		stage--
		update_temp()
		sleep(30)
	qdel(src)

/datum/hallucination/shock
	var/image/shock_image
	var/image/electrocution_skeleton_anim

/datum/hallucination/shock/New(mob/living/carbon/C, forced = TRUE)
	set waitfor = FALSE
	..()
	shock_image = image(target, target, dir = target.dir)
	shock_image.appearance_flags |= KEEP_APART
	shock_image.color = rgb(0,0,0)
	shock_image.override = TRUE
	electrocution_skeleton_anim = image('icons/mob/human.dmi', target, icon_state = "electrocuted_base", layer=ABOVE_MOB_LAYER)
	electrocution_skeleton_anim.appearance_flags |= RESET_COLOR|KEEP_APART
	to_chat(target, span_userdanger("You feel a powerful shock course through your body!"))
	if(target.client)
		target.client.images |= shock_image
		target.client.images |= electrocution_skeleton_anim
	addtimer(CALLBACK(src, PROC_REF(reset_shock_animation)), 40)
	target.playsound_local(get_turf(src), "sparks", 100, 1)
	target.staminaloss += 50
	target.Stun(40)
	target.set_timed_status_effect(300 SECONDS, /datum/status_effect/jitter, only_if_higher = TRUE)
	addtimer(CALLBACK(src, PROC_REF(shock_drop)), 20)

/datum/hallucination/shock/proc/reset_shock_animation()
	if(target.client)
		target.client.images.Remove(shock_image)
		target.client.images.Remove(electrocution_skeleton_anim)

/datum/hallucination/shock/proc/shock_drop()
	target.set_timed_status_effect(20 SECONDS, /datum/status_effect/jitter)
	target.Paralyze(60)

/datum/hallucination/husks

/datum/hallucination/husks/New(mob/living/carbon/C, forced = TRUE)
	set waitfor = FALSE
	..()
	if(!target.halbody)
		var/list/possible_points = list()
		for(var/turf/open/floor/F in view(target,world.view))
			possible_points += F
		if(possible_points.len)
			var/turf/open/floor/husk_point = pick(possible_points)
			switch(rand(1,4))
				if(1)
					var/image/body = image('icons/mob/human.dmi',husk_point,"husk",TURF_LAYER)
					var/matrix/M = matrix()
					M.Turn(90)
					body.transform = M
					target.halbody = body
				if(2,3)
					target.halbody = image('icons/mob/human.dmi',husk_point,"husk",TURF_LAYER)
				if(4)
					target.halbody = image('icons/mob/alien.dmi',husk_point,"alienother",TURF_LAYER)

			if(target.client)
				target.client.images += target.halbody
			sleep(rand(30,50)) //Only seen for a brief moment.
			if(target.client)
				target.client.images -= target.halbody
			QDEL_NULL(target.halbody)
	qdel(src)

//hallucination projectile code in code/modules/projectiles/projectile/special.dm
/datum/hallucination/stray_bullet

/datum/hallucination/stray_bullet/New(mob/living/carbon/C, forced = TRUE)
	set waitfor = FALSE
	..()
	var/list/turf/startlocs = list()
	for(var/turf/open/T in view(world.view+1,target)-view(world.view,target))
		startlocs += T
	if(!startlocs.len)
		qdel(src)
		return
	var/turf/start = pick(startlocs)
	var/proj_type = pick(subtypesof(/obj/projectile/hallucination))
	feedback_details += "Type: [proj_type]"
	var/obj/projectile/hallucination/H = new proj_type(start)
	target.playsound_local(start, H.hal_fire_sound, 60, 1)
	H.hal_target = target
	H.preparePixelProjectile(target, start)
	H.fire()
	qdel(src)

//WS Begin - Borers
/obj/effect/hallucination/simple/borer
	image_icon = 'icons/mob/borer.dmi'
	image_state = "brainslug"

/datum/hallucination/borer
	var/obj/effect/hallucination/simple/borer/borer
	var/obj/machinery/atmospherics/components/unary/vent_pump/pump

/datum/hallucination/borer/New(mob/living/carbon/C, forced = TRUE)
	set waitfor = FALSE
	. = ..()
	for(var/obj/machinery/atmospherics/components/unary/vent_pump/U in orange(7,target))
		if(!U.welded)
			pump = U
			break
	if(pump)
		borer = new(pump.loc, C)
		for(var/i=0, i<11, i++)
			walk_to(borer, get_step(borer, get_cardinal_dir(borer, C)))
			if(borer.Adjacent(C))
				target.visible_message(span_warning("Shivers slightly."),span_userdanger("You feel a creeping, horrible sense of dread come over you, freezing your limbs and setting your heart racing."))
				C.Paralyze(60)
				QDEL_IN(50, borer)
				sleep(rand(60, 90))
				to_chat(C, span_changeling("<i>Primary [rand(1000,9999)] states:</i> [pick("Hello","Hi","You're my slave now!","Don't try to get rid of me...")]"))
				break
			sleep(4)
		if(!QDELETED(borer))
			qdel(borer)
	qdel(src)

//WS end
