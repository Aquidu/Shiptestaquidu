#define WHITE_TEAM "White"
#define RED_TEAM "Red"
#define BLUE_TEAM "Blue"
#define FLAG_RETURN_TIME 200 // 20 seconds
#define INSTAGIB_RESPAWN 50 //5 seconds
#define DEFAULT_RESPAWN 150 //15 seconds
#define AMMO_DROP_LIFETIME 300
#define CTF_REQUIRED_PLAYERS 4



/obj/item/ctf
	name = "banner"
	icon = 'icons/obj/banner.dmi'
	icon_state = "banner"
	item_state = "banner"
	lefthand_file = 'icons/mob/inhands/equipment/banners_lefthand.dmi'
	righthand_file = 'icons/mob/inhands/equipment/banners_righthand.dmi'
	desc = "A banner with Nanotrasen's logo on it."
	slowdown = 2
	throw_speed = 0
	throw_range = 1
	force = 200
	armour_penetration = 1000
	resistance_flags = INDESTRUCTIBLE
	anchored = TRUE
	item_flags = SLOWS_WHILE_IN_HAND
	var/team = WHITE_TEAM
	var/reset_cooldown = 0
	var/anyonecanpickup = TRUE
	var/obj/effect/ctf/flag_reset/reset
	var/reset_path = /obj/effect/ctf/flag_reset

/obj/item/ctf/Destroy()
	QDEL_NULL(reset)
	return ..()

/obj/item/ctf/Initialize()
	. = ..()
	if(!reset)
		reset = new reset_path(get_turf(src))
		reset.flag = src
	RegisterSignal(src, COMSIG_PREQDELETED, PROC_REF(reset_flag)) //just in case CTF has some map hazards (read: chasms).

/obj/item/ctf/ComponentInitialize()
	. = ..()
	AddComponent(/datum/component/two_handed)

/obj/item/ctf/proc/reset_flag(capture = FALSE)
	SIGNAL_HANDLER

	var/turf/our_turf = get_turf(src.reset)
	if(!our_turf)
		return TRUE
	forceMove(our_turf)
	for(var/mob/M in GLOB.player_list)
		var/area/mob_area = get_area(M)
		if(istype(mob_area, /area/ctf))
			if(!capture)
				to_chat(M, span_userdanger("[src] has been returned to the base!"))
	STOP_PROCESSING(SSobj, src)
	return TRUE //so if called by a signal, it doesn't delete

/obj/item/ctf/dropped(mob/user)
	..()
	user.set_anchored(FALSE)
	user.status_flags |= CANPUSH
	reset_cooldown = world.time + 200 //20 seconds
	START_PROCESSING(SSobj, src)
	for(var/mob/M in GLOB.player_list)
		var/area/mob_area = get_area(M)
		if(istype(mob_area, /area/ctf))
			to_chat(M, span_userdanger("\The [src] has been dropped!"))
	anchored = TRUE


/obj/item/ctf/red
	name = "red flag"
	icon_state = "banner-red"
	item_state = "banner-red"
	desc = "A red banner used to play capture the flag."
	team = RED_TEAM
	reset_path = /obj/effect/ctf/flag_reset/red


/obj/item/ctf/blue
	name = "blue flag"
	icon_state = "banner-blue"
	item_state = "banner-blue"
	desc = "A blue banner used to play capture the flag."
	team = BLUE_TEAM
	reset_path = /obj/effect/ctf/flag_reset/blue

/obj/effect/ctf/flag_reset
	name = "banner landmark"
	icon = 'icons/obj/banner.dmi'
	icon_state = "banner"
	desc = "This is where a banner with Nanotrasen's logo on it would go."
	layer = LOW_ITEM_LAYER
	var/obj/item/ctf/flag

/obj/effect/ctf/flag_reset/Destroy()
	if(flag)
		flag.reset = null
		flag = null
	return ..()

/obj/effect/ctf/flag_reset/red
	name = "red flag landmark"
	icon_state = "banner-red"
	desc = "This is where a red banner used to play capture the flag \
		would go."

/obj/effect/ctf/flag_reset/blue
	name = "blue flag landmark"
	icon_state = "banner-blue"
	desc = "This is where a blue banner used to play capture the flag \
		would go."

/proc/toggle_all_ctf(mob/user)
	var/ctf_enabled = FALSE
	var/area/A
	for(var/obj/machinery/capture_the_flag/CTF in GLOB.machines)
		ctf_enabled = CTF.toggle_ctf()
		A = get_area(CTF)
	for(var/obj/machinery/power/emitter/E in A)
		E.active = ctf_enabled
	message_admins("[key_name_admin(user)] has [ctf_enabled? "enabled" : "disabled"] CTF!")
	notify_ghosts("CTF has been [ctf_enabled? "enabled" : "disabled"]!",'sound/effects/ghost2.ogg')

/obj/machinery/capture_the_flag
	name = "CTF Controller"
	desc = "Used for running friendly games of capture the flag."
	icon = 'icons/obj/device.dmi'
	icon_state = "syndbeacon"
	resistance_flags = INDESTRUCTIBLE
	processing_flags = START_PROCESSING_MANUALLY
	var/team = WHITE_TEAM
	var/team_span = ""
	//Capture the Flag scoring
	var/points = 0
	var/points_to_win = 3
	var/respawn_cooldown = DEFAULT_RESPAWN
	//Capture Point/King of the Hill scoring
	var/control_points = 0
	var/control_points_to_win = 180
	var/list/team_members = list()
	var/list/spawned_mobs = list()
	var/list/recently_dead_ckeys = list()
	var/ctf_enabled = FALSE
	var/ctf_gear = /datum/outfit/ctf

	var/list/dead_barricades = list()

	var/static/arena_reset = FALSE
	var/static/list/people_who_want_to_play = list()

/obj/machinery/capture_the_flag/Initialize()
	. = ..()
	SSpoints_of_interest.make_point_of_interest(src)

/obj/machinery/capture_the_flag/Destroy()
	SSpoints_of_interest.remove_point_of_interest(src)
	return ..()

/obj/machinery/capture_the_flag/process(seconds_per_tick)
	for(var/i in spawned_mobs)
		// Anyone in crit, automatically reap
		var/mob/living/living_participant = i
		if(HAS_TRAIT(living_participant, TRAIT_CRITICAL_CONDITION) || living_participant.stat == DEAD)
			ctf_dust_old(living_participant)
			spawned_mobs -= living_participant
		else
			// The changes that you've been hit with no shield but not
			// instantly critted are low, but have some healing.
			living_participant.adjustBruteLoss(-2.5 * seconds_per_tick)
			living_participant.adjustFireLoss(-2.5 * seconds_per_tick)

//ATTACK GHOST IGNORING PARENT RETURN VALUE
/obj/machinery/capture_the_flag/attack_ghost(mob/user)
	if(ctf_enabled == FALSE)
		if(user.client && user.client.holder)
			var/response = alert("Enable CTF?", "CTF", "Yes", "No")
			if(response == "Yes")
				toggle_all_ctf(user)
			return


		people_who_want_to_play |= user.ckey
		var/num = people_who_want_to_play.len
		var/remaining = CTF_REQUIRED_PLAYERS - num
		if(remaining <= 0)
			people_who_want_to_play.Cut()
			toggle_all_ctf()
		else
			to_chat(user, span_notice("CTF has been requested. [num]/[CTF_REQUIRED_PLAYERS] have readied up."))

		return

	if(!SSticker.HasRoundStarted())
		return
	if(user.ckey in team_members)
		if(user.ckey in recently_dead_ckeys)
			to_chat(user, span_warning("It must be more than [DisplayTimeText(respawn_cooldown)] from your last death to respawn!"))
			return
		var/client/new_team_member = user.client
		if(user.mind && user.mind.current)
			ctf_dust_old(user.mind.current)
		spawn_team_member(new_team_member)
		return

	for(var/obj/machinery/capture_the_flag/CTF in GLOB.machines)
		if(CTF == src || CTF.ctf_enabled == FALSE)
			continue
		if(user.ckey in CTF.team_members)
			to_chat(user, span_warning("No switching teams while the round is going!"))
			return
		if(CTF.team_members.len < src.team_members.len)
			to_chat(user, span_warning("[src.team] has more team members than [CTF.team]! Try joining [CTF.team] team to even things up."))
			return
	team_members |= user.ckey
	var/client/new_team_member = user.client
	if(user.mind && user.mind.current)
		ctf_dust_old(user.mind.current)
	spawn_team_member(new_team_member)

/obj/machinery/capture_the_flag/proc/ctf_dust_old(mob/living/body)
	if(isliving(body) && (team in body.faction))
		var/turf/T = get_turf(body)
		new /obj/effect/ctf/ammo(T)
		recently_dead_ckeys += body.ckey
		addtimer(CALLBACK(src, PROC_REF(clear_cooldown), body.ckey), respawn_cooldown, TIMER_UNIQUE)
		body.dust()

/obj/machinery/capture_the_flag/proc/clear_cooldown(ckey)
	recently_dead_ckeys -= ckey

/obj/machinery/capture_the_flag/proc/spawn_team_member(client/new_team_member)
	var/mob/living/carbon/human/M = new/mob/living/carbon/human(get_turf(src))
	new_team_member.prefs.copy_to(M)
	M.key = new_team_member.key
	M.faction += team
	M.equipOutfit(ctf_gear)
	spawned_mobs += M

/obj/machinery/capture_the_flag/Topic(href, href_list)
	if(href_list["join"])
		var/mob/dead/observer/ghost = usr
		if(istype(ghost))
			attack_ghost(ghost)

/obj/machinery/capture_the_flag/attackby(obj/item/I, mob/user, params)
	if(istype(I, /obj/item/ctf))
		var/obj/item/ctf/flag = I
		if(flag.team != src.team)
			user.transferItemToLoc(flag, get_turf(flag.reset), TRUE)
			points++
			for(var/mob/M in GLOB.player_list)
				var/area/mob_area = get_area(M)
				if(istype(mob_area, /area/ctf))
					to_chat(M, "<span class='userdanger [team_span]'>[user.real_name] has captured \the [flag], scoring a point for [team] team! They now have [points]/[points_to_win] points!</span>")
		if(points >= points_to_win)
			victory()

/obj/machinery/capture_the_flag/proc/victory()
	for(var/mob/M in GLOB.mob_list)
		var/area/mob_area = get_area(M)
		if(istype(mob_area, /area/ctf))
			to_chat(M, "<span class='narsie [team_span]'>[team] team wins!</span>")
			to_chat(M, span_userdanger("Teams have been cleared. Click on the machines to vote to begin another round."))
			for(var/obj/item/ctf/W in M)
				M.dropItemToGround(W)
			M.dust()
	for(var/obj/machinery/control_point/control in GLOB.machines)
		control.icon_state = "dominator"
		control.controlling = null
	for(var/obj/machinery/capture_the_flag/CTF in GLOB.machines)
		if(CTF.ctf_enabled == TRUE)
			CTF.points = 0
			CTF.control_points = 0
			CTF.ctf_enabled = FALSE
			CTF.team_members = list()
			CTF.arena_reset = FALSE

/obj/machinery/capture_the_flag/proc/toggle_ctf()
	if(!ctf_enabled)
		start_ctf()
		. = TRUE
	else
		stop_ctf()
		. = FALSE

/obj/machinery/capture_the_flag/proc/start_ctf()
	ctf_enabled = TRUE
	START_PROCESSING(SSmachines, src)
	for(var/d in dead_barricades)
		var/obj/effect/ctf/dead_barricade/D = d
		D.respawn()

	dead_barricades.Cut()

	notify_ghosts("[name] has been activated!", enter_link="<a href=?src=[REF(src)];join=1>(Click to join the [team] team!)</a> or click on the controller directly!", source = src, action=NOTIFY_ATTACK, header = "CTF has been activated")

	if(!arena_reset)
		reset_the_arena()
		arena_reset = TRUE

/obj/machinery/capture_the_flag/proc/reset_the_arena()
	var/area/A = get_area(src)
	var/list/ctf_object_typecache = typecacheof(list(
				/obj/machinery,
				/obj/effect/ctf,
				/obj/item/ctf
			))
	for(var/atm in A)
		if (isturf(A) || ismob(A) || isarea(A))
			continue
		if(isstructure(atm))
			var/obj/structure/S = atm
			S.update_integrity(S.max_integrity)
		else if(!is_type_in_typecache(atm, ctf_object_typecache))
			qdel(atm)


/obj/machinery/capture_the_flag/proc/stop_ctf()
	ctf_enabled = FALSE
	STOP_PROCESSING(SSmachines, src)
	arena_reset = FALSE
	var/area/A = get_area(src)
	for(var/i in GLOB.mob_list)
		var/mob/M = i
		if((get_area(A) == A) && (M.ckey in team_members))
			M.dust()
	team_members.Cut()
	spawned_mobs.Cut()
	recently_dead_ckeys.Cut()

/obj/machinery/capture_the_flag/proc/instagib_mode()
	for(var/obj/machinery/capture_the_flag/CTF in GLOB.machines)
		if(CTF.ctf_enabled == TRUE)
			CTF.ctf_gear = CTF.instagib_gear
			CTF.respawn_cooldown = INSTAGIB_RESPAWN

/obj/machinery/capture_the_flag/proc/normal_mode()
	for(var/obj/machinery/capture_the_flag/CTF in GLOB.machines)
		if(CTF.ctf_enabled == TRUE)
			CTF.ctf_gear = initial(ctf_gear)
			CTF.respawn_cooldown = DEFAULT_RESPAWN

/obj/item/gun/ballistic/automatic/laser
	bad_type = /obj/item/gun/ballistic/automatic/laser
	spawn_blacklisted = TRUE

// RED TEAM GUNS

/obj/item/gun/ballistic/automatic/assault/skm/ctf
	desc = "An obsolete model of assault rifle once used by CLIP. This rifle will disintegrate if dropped."

/obj/item/gun/ballistic/automatic/assault/skm/ctf/dropped()
	. = ..()
	addtimer(CALLBACK(src, PROC_REF(floor_vanish)), 30)

/obj/item/gun/ballistic/automatic/assault/skm/ctf/proc/floor_vanish()
	if(isturf(loc))
		qdel(src)

/obj/item/ammo_box/magazine/skm_762_40/ctf
	desc = "A slightly curved, 20-round magazine for the 7.62x40mm CLIP variants of the SKM assault rifle family. These magazines will disintegrate if dropped."

/obj/item/ammo_box/magazine/skm_762_40/ctf/dropped()
	. = ..()
	addtimer(CALLBACK(src, PROC_REF(floor_vanish)), 1)

/obj/item/ammo_box/magazine/skm_762_40/ctf/proc/floor_vanish()
	if(isturf(loc))
		qdel(src)

/obj/item/storage/belt/security/military/frontiersmen/skm_ammo/ctf/ComponentInitialize()
	. = ..()
	var/datum/component/storage/STR = GetComponent(/datum/component/storage)
	STR.max_items = 6

/obj/item/storage/belt/security/military/frontiersmen/skm_ammo/ctf/PopulateContents()
	for(var/i in 1 to 3)
		new /obj/item/ammo_box/magazine/skm_762_40/ctf(src)
	new /obj/item/grenade/frag(src)
	new /obj/item/gun/ballistic/automatic/pistol/mauler/regular/ctf(src)
	new /obj/item/melee/knife/combat/ctf(src)

/obj/item/gun/ballistic/automatic/pistol/mauler/regular/ctf
	desc = "A semi-automatic 9mm handgun frequently used by the Frontiersmen. This sidearm will disintegrate if dropped."

/obj/item/gun/ballistic/automatic/pistol/mauler/regular/ctf/dropped()
	. = ..()
	addtimer(CALLBACK(src, PROC_REF(floor_vanish)), 30)

/obj/item/gun/ballistic/automatic/pistol/mauler/regular/ctf/proc/floor_vanish()
	if(isturf(loc))
		qdel(src)

/obj/item/ammo_box/magazine/m9mm_mauler/ctf
	desc = "A 8-round magazine designed for the Mauler pistol. These magazines will disintegrate if dropped."

/obj/item/ammo_box/magazine/m9mm_mauler/ctf/dropped()
	. = ..()
	addtimer(CALLBACK(src, PROC_REF(floor_vanish)), 1)

/obj/item/ammo_box/magazine/m9mm_mauler/ctf/proc/floor_vanish()
	if(isturf(loc))
		qdel(src)

// BLUE TEAM GUNS

/obj/item/gun/ballistic/automatic/assault/cm82/ctf
	desc = "CLIP's standard assault rifle, a relatively new service weapon. This rifle will disintegrate if dropped."

/obj/item/gun/ballistic/automatic/assault/cm82/dropped()
	. = ..()
	addtimer(CALLBACK(src, PROC_REF(floor_vanish)), 30)

/obj/item/gun/ballistic/automatic/assault/cm82/proc/floor_vanish()
	if(isturf(loc))
		qdel(src)

/obj/item/ammo_box/magazine/p16/ctf
	desc = "A simple, 30-round magazine for 5.56x42mm CLIP assault rifles. These magazines will disintegrate if dropped."

/obj/item/ammo_box/magazine/p16/ctf/dropped()
	. = ..()
	addtimer(CALLBACK(src, PROC_REF(floor_vanish)), 1)

/obj/item/ammo_box/magazine/p16/ctf/proc/floor_vanish()
	if(isturf(loc))
		qdel(src)

/obj/item/storage/belt/military/clip/cm82/ctf/ComponentInitialize()
	. = ..()
	var/datum/component/storage/STR = GetComponent(/datum/component/storage)
	STR.max_items = 6

/obj/item/storage/belt/military/clip/cm82/ctf/PopulateContents()
	for(var/i in 1 to 3)
		new /obj/item/ammo_box/magazine/p16/ctf(src)
	new /obj/item/grenade/frag(src)
	new /obj/item/gun/ballistic/automatic/pistol/cm23/ctf(src)
	new /obj/item/melee/knife/combat/ctf(src)

/obj/item/gun/ballistic/automatic/pistol/cm23/ctf
	desc = "CLIP's standard service pistol, chambered in 10mm. This sidearm will disintegrate if dropped."

/obj/item/gun/ballistic/automatic/pistol/cm23/ctf/dropped()
	. = ..()
	addtimer(CALLBACK(src, PROC_REF(floor_vanish)), 30)

/obj/item/gun/ballistic/automatic/pistol/cm23/ctf/proc/floor_vanish()
	if(isturf(loc))
		qdel(src)

/obj/item/ammo_box/magazine/cm23/ctf
		desc = "An 10-round magazine magazine designed for the CM-23 pistol. These magazines will disintegrate if dropped."

/obj/item/ammo_box/magazine/cm23/ctf/dropped()
	. = ..()
	addtimer(CALLBACK(src, PROC_REF(floor_vanish)), 1)

/obj/item/ammo_box/magazine/cm23/ctf/proc/floor_vanish()
	if(isturf(loc))
		qdel(src)

/obj/structure/trap/ctf/examine(mob/user)
	return

/obj/structure/barricade/security/ctf
	name = "barrier"
	desc = "A barrier. Provides cover in fire fights."
	deploy_time = 0
	deploy_message = 0

/obj/structure/barricade/security/ctf/make_debris()
	new /obj/effect/ctf/dead_barricade(get_turf(src))

/obj/effect/ctf
	density = FALSE
	anchored = TRUE
	invisibility = INVISIBILITY_OBSERVER
	alpha = 100
	resistance_flags = INDESTRUCTIBLE

/obj/effect/ctf/ammo
	name = "ammo pickup"
	desc = "You like revenge, right? Everybody likes revenge! Well, \
		let's go get some!"
	icon = 'icons/effects/effects.dmi'
	icon_state = "at_shield1"
	layer = ABOVE_MOB_LAYER
	alpha = 255
	invisibility = 0

/obj/effect/ctf/ammo/Initialize(mapload)
	. = ..()
	var/static/list/loc_connections = list(
		COMSIG_ATOM_ENTERED = PROC_REF(on_entered),
	)
	AddElement(/datum/element/connect_loc, loc_connections)
	QDEL_IN(src, AMMO_DROP_LIFETIME)

/obj/effect/ctf/ammo/proc/on_entered(datum/source, atom/movable/AM)
	SIGNAL_HANDLER
	reload(AM)

/obj/effect/ctf/ammo/Bump(atom/A)
	reload(A)

/obj/effect/ctf/ammo/Bumped(atom/movable/AM)
	reload(AM)

/obj/effect/ctf/ammo/proc/reload(mob/living/M)
	if(!ishuman(M))
		return
	for(var/obj/machinery/capture_the_flag/CTF in GLOB.machines)
		if(M in CTF.spawned_mobs)
			var/outfit = CTF.ctf_gear
			var/datum/outfit/O = new outfit
			for(var/obj/item/gun/G in M)
				qdel(G)
			O.equip(M)
			to_chat(M, span_notice("Ammunition reloaded!"))
			playsound(get_turf(M), 'sound/weapons/gun/shotgun/rack.ogg', 50, TRUE, -1)
			qdel(src)
			break

/obj/effect/ctf/dead_barricade
	name = "dead barrier"
	desc = "It provided cover in fire fights. And now it's gone."
	icon = 'icons/obj/objects.dmi'
	icon_state = "barrier0"

/obj/effect/ctf/dead_barricade/Initialize(mapload)
	. = ..()
	for(var/obj/machinery/capture_the_flag/CTF in GLOB.machines)
		CTF.dead_barricades += src

/obj/effect/ctf/dead_barricade/Destroy()
	for(var/obj/machinery/capture_the_flag/CTF in GLOB.machines)
		CTF.dead_barricades -= src
	return ..()

/obj/effect/ctf/dead_barricade/proc/respawn()
	if(!QDELETED(src))
		new /obj/structure/barricade/security/ctf(get_turf(src))
		qdel(src)


//Control Point

/obj/machinery/control_point
	name = "control point"
	desc = "You should capture this."
	icon = 'icons/obj/machines/dominator.dmi'
	icon_state = "dominator"
	resistance_flags = INDESTRUCTIBLE
	var/obj/machinery/capture_the_flag/controlling
	var/team = "none"
	var/point_rate = 0.5

/obj/machinery/control_point/process(seconds_per_tick)
	if(controlling)
		controlling.control_points += point_rate * seconds_per_tick
		if(controlling.control_points >= controlling.control_points_to_win)
			controlling.victory()

/obj/machinery/control_point/attackby(mob/user, params)
	capture(user)

/obj/machinery/control_point/attack_hand(mob/user)
	. = ..()
	if(.)
		return
	capture(user)

/obj/machinery/control_point/proc/capture(mob/user)
	if(do_after(user, 30, target = src))
		for(var/obj/machinery/capture_the_flag/CTF in GLOB.machines)
			if(CTF.ctf_enabled && (user.ckey in CTF.team_members))
				controlling = CTF
				icon_state = "dominator-[CTF.team]"
				for(var/mob/M in GLOB.player_list)
					var/area/mob_area = get_area(M)
					if(istype(mob_area, /area/ctf))
						to_chat(M, span_userdanger("[user.real_name] has captured \the [src], claiming it for [CTF.team]! Go take it back!"))
				break

#undef WHITE_TEAM
#undef RED_TEAM
#undef BLUE_TEAM
#undef FLAG_RETURN_TIME
#undef INSTAGIB_RESPAWN
#undef DEFAULT_RESPAWN
#undef AMMO_DROP_LIFETIME
#undef CTF_REQUIRED_PLAYERS
