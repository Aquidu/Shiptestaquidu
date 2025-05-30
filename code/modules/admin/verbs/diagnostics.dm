/client/proc/air_status(turf/target)
	set category = "Debug.Debug"
	set name = "Display Air Status"

	if(!isturf(target))
		return
	atmosanalyzer_scan(usr, target, TRUE)
	BLACKBOX_LOG_ADMIN_VERB("Show Air Status")

/client/proc/fix_next_move()
	set category = "Debug"
	set name = "Unfreeze Everyone"
	var/largest_move_time = 0
	var/largest_click_time = 0
	var/mob/largest_move_mob = null
	var/mob/largest_click_mob = null
	for(var/mob/M in world)
		if(!M.client)
			continue
		if(M.next_move >= largest_move_time)
			largest_move_mob = M
			if(M.next_move > world.time)
				largest_move_time = M.next_move - world.time
			else
				largest_move_time = 1
		if(M.next_click >= largest_click_time)
			largest_click_mob = M
			if(M.next_click > world.time)
				largest_click_time = M.next_click - world.time
			else
				largest_click_time = 0
		log_admin("DEBUG: [key_name(M)]  next_move = [M.next_move]  lastDblClick = [M.next_click]  world.time = [world.time]")
		M.next_move = 1
		M.next_click = 0
	message_admins("[ADMIN_LOOKUPFLW(largest_move_mob)] had the largest move delay with [largest_move_time] frames / [DisplayTimeText(largest_move_time)]!")
	message_admins("[ADMIN_LOOKUPFLW(largest_click_mob)] had the largest click delay with [largest_click_time] frames / [DisplayTimeText(largest_click_time)]!")
	message_admins("world.time = [world.time]")
	BLACKBOX_LOG_ADMIN_VERB("Unfreeze Everyone")
	return

/client/proc/radio_report()
	set category = "Debug"
	set name = "Radio report"

	var/output = "<b>Radio Report</b><hr>"
	for (var/fq in SSradio.frequencies)
		output += "<b>Freq: [fq]</b><br>"
		var/datum/radio_frequency/fqs = SSradio.frequencies[fq]
		if (!fqs)
			output += "&nbsp;&nbsp;<b>ERROR</b><br>"
			continue
		for (var/filter in fqs.devices)
			var/list/f = fqs.devices[filter]
			if (!f)
				output += "&nbsp;&nbsp;[filter]: ERROR<br>"
				continue
			output += "&nbsp;&nbsp;[filter]: [f.len]<br>"
			for (var/device in f)
				if (istype(device, /atom))
					var/atom/A = device
					output += "&nbsp;&nbsp;&nbsp;&nbsp;[device] ([AREACOORD(A)])<br>"
				else
					output += "&nbsp;&nbsp;&nbsp;&nbsp;[device]<br>"

	usr << browse(output,"window=radioreport")
	BLACKBOX_LOG_ADMIN_VERB("Show Radio Report")

/client/proc/reload_admins()
	set name = "Reload Admins"
	set category = "Admin"

	if(!src.holder)
		return

	var/confirm = alert(src, "Are you sure you want to reload all admins and mentors?", "Confirm", "Yes", "No")
	if(confirm !="Yes")
		return

	load_admins()
	load_mentors()
	BLACKBOX_LOG_ADMIN_VERB("Reload All Admins")
	message_admins("[key_name_admin(usr)] manually reloaded admins")

/client/proc/toggle_cdn()
	set name = "Toggle CDN"
	set category = "Server"
	var/static/admin_disabled_cdn_transport = null
	if (alert(usr, "Are you sure you want to toggle the CDN asset transport?", "Confirm", "Yes", "No") != "Yes")
		return
	var/current_transport = CONFIG_GET(string/asset_transport)
	if (!current_transport || current_transport == "simple")
		if (admin_disabled_cdn_transport)
			CONFIG_SET(string/asset_transport, admin_disabled_cdn_transport)
			admin_disabled_cdn_transport = null
			SSassets.OnConfigLoad()
			message_admins("[key_name_admin(usr)] re-enabled the CDN asset transport")
			log_admin("[key_name(usr)] re-enabled the CDN asset transport")
		else
			to_chat(usr, span_adminnotice("The CDN is not enabled!"))
			if (alert(usr, "The CDN asset transport is not enabled! If you having issues with assets you can also try disabling filename mutations.", "The CDN asset transport is not enabled!", "Try disabling filename mutations", "Nevermind") == "Try disabling filename mutations")
				SSassets.transport.dont_mutate_filenames = !SSassets.transport.dont_mutate_filenames
				message_admins("[key_name_admin(usr)] [(SSassets.transport.dont_mutate_filenames ? "disabled" : "re-enabled")] asset filename transforms")
				log_admin("[key_name(usr)] [(SSassets.transport.dont_mutate_filenames ? "disabled" : "re-enabled")] asset filename transforms")
	else
		admin_disabled_cdn_transport = current_transport
		CONFIG_SET(string/asset_transport, "simple")
		SSassets.OnConfigLoad()
		SSassets.transport.dont_mutate_filenames = TRUE
		message_admins("[key_name_admin(usr)] disabled the CDN asset transport")
		log_admin("[key_name(usr)] disabled the CDN asset transport")
