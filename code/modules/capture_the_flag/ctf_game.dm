#define WHITE_TEAM "White"
#define RED_TEAM "Frontiersmen"
#define BLUE_TEAM "CLIP"
#define FLAG_RETURN_TIME 20 SECONDS

///Base CTF machines, if spawned in creates a CTF game with the provided game_id unless one already exists. If one exists associates itself with it.
/obj/machinery/ctf
	name = "CTF Controller"
	desc = "Used for running friendly games of capture the flag."
	icon = 'icons/obj/machines/sleeper.dmi'
	icon_state = "sleeper"
	density = TRUE
	resistance_flags = INDESTRUCTIBLE | LAVA_PROOF | FIRE_PROOF | UNACIDABLE | ACID_PROOF
	///The game ID that this CTF machine is associated with.
	var/game_id = CTF_GHOST_CTF_GAME_ID
	///Reference to the CTF controller that this machine operates under.
	var/datum/ctf_controller/ctf_game

/obj/machinery/ctf/Initialize(mapload)
	. = ..()
	ctf_game = GLOB.ctf_games[game_id]
	if(isnull(ctf_game))
		ctf_game = create_ctf_game(game_id)

///A spawn point for CTF, ghosts can interact with this to vote for CTF or spawn in if a game is running.
/obj/machinery/ctf/spawner
	///The team that this spawner is associated with.
	var/team = WHITE_TEAM
	///The span applied to messages associated with this team.
	var/team_span = ""
	///assoc list for classes. If there's only one, it'll just equip. Otherwise, it lets you pick which outfit!
	var/list/ctf_gear = list("Rifleman" = /datum/outfit/ctf)
	///Var that holds a copy of ctf_gear so that if instagib mode is enabled (overwritting ctf_gear) it can be reverted with this var.
	var/list/default_gear = list()
	///The powerup dropped when a player spawned by this controller dies.
	var/ammo_type = /obj/effect/ctf/ammo
	// Fast paced gameplay, no real time for burn infections.
	var/player_traits = list(TRAIT_NEVER_WOUNDED)

/obj/machinery/ctf/spawner/Initialize(mapload)
	. = ..()
	ctf_game.add_team(src)
	SSpoints_of_interest.make_point_of_interest(src)
	default_gear = ctf_gear

/obj/machinery/ctf/spawner/Destroy()
	ctf_game.remove_team(team)
	return ..()

/obj/machinery/ctf/spawner/red
	name = "Frontiersmen Avatar Generator"
	desc = "A high-tech machine used to generate Frontiersmen avatars as a part of the CLIP Minutemen's virtual training simulation. It's fashioned to look like a cryopod."
	icon_state = "frontiersmen-spawner"
	team = RED_TEAM
	team_span = "redteamradio"
	ctf_gear = list(
		"Rifleman" = /datum/outfit/ctf/frontiersman/rifleman,
		"Engineer" = /datum/outfit/ctf/frontiersman/engineer,
		"Marksman" = /datum/outfit/ctf/frontiersman/marksman,
		"Medic" = /datum/outfit/ctf/frontiersman/medic,
		"Breacher" = /datum/outfit/ctf/frontiersman/breacher,
		"Specialist" = /datum/outfit/ctf/frontiersman/specialist
	)

/obj/machinery/ctf/spawner/blue
	name = "Minutemen Avatar Generator"
	desc = "A high-tech machine used to generate Minutemen avatars as a part of the CLIP Minutemen's virtual training simulation. It's fashioned to look like a cryopod."
	icon_state = "clip-spawner"
	team = BLUE_TEAM
	team_span = "blueteamradio"
	ctf_gear = list(
	"Rifleman" = /datum/outfit/ctf/clip/rifleman,
	"Engineer" = /datum/outfit/ctf/clip/engineer,
	"Marksman" = /datum/outfit/ctf/clip/marksman,
	"Medic" = /datum/outfit/ctf/clip/medic,
	"Breacher" = /datum/outfit/ctf/clip/breacher,
	"Specialist" = /datum/outfit/ctf/clip/specialist
	)

/obj/machinery/ctf/spawner/attack_ghost(mob/user)
	if(ctf_game.ctf_enabled == FALSE)
		if(user.client && user.client.holder)
			var/response = tgui_alert(user, "Enable this CTF game?", "CTF", list("Yes", "No"))
			if(response == "Yes")
				toggle_id_ctf(user, game_id)
			return
	if(!SSticker.HasRoundStarted())
		to_chat(user, span_warning("Please wait until the round has started."))
		return
	if(user.ckey in ctf_game.get_players(team))
		var/datum/component/ctf_player/ctf_player_component = ctf_game.get_player_component(team, user.ckey)
		var/client/new_team_member = user.client
		if(isnull(ctf_player_component))
			spawn_team_member(new_team_member) //Player managed to lose their player component despite being on a team
		else
			if(ctf_player_component.can_respawn)
				spawn_team_member(new_team_member, ctf_player_component)
			else
				to_chat(user, span_warning("You cannot respawn yet!"))
		return
	if(ctf_game.team_valid_to_join(team, user))
		to_chat(user, span_userdanger("You are now a member of [src.team]. Get the enemy flag and bring it back to your team's controller!"))
		ctf_game.add_player(team, user.ckey)
		var/client/new_team_member = user.client
		spawn_team_member(new_team_member)

/obj/machinery/ctf/spawner/Topic(href, href_list)
	if(href_list["join"])
		var/mob/dead/observer/ghost = usr
		if(istype(ghost))
			attack_ghost(ghost)

/obj/machinery/ctf/spawner/proc/spawn_team_member(client/new_team_member, datum/component/ctf_player/ctf_player_component)
	var/datum/outfit/chosen_class

	if(ctf_gear.len == 1) //no choices to make
		for(var/key in ctf_gear)
			chosen_class = ctf_gear[key]

	else //There's a choice to make, present a radial menu
		var/list/display_classes = list()

		for(var/key in ctf_gear)
			var/datum/outfit/ctf/class = ctf_gear[key]
			var/datum/radial_menu_choice/option = new
			option.image  = image(icon = initial(class.icon), icon_state = initial(class.icon_state))
			option.info = span_boldnotice("[initial(class.class_description)]")
			display_classes[key] = option

		sortList(display_classes)
		var/choice = show_radial_menu(new_team_member.mob, src, display_classes, radius = 38)
		if(!choice || !(GLOB.ghost_role_flags & GHOSTROLE_CTF) || !isobserver(new_team_member.mob) || ctf_game.ctf_enabled == FALSE || !(new_team_member.ckey in ctf_game.get_players(team)))
			return //picked nothing, admin disabled it, cheating to respawn faster, cheating to respawn... while in game?,
				   //there isn't a game going on any more, you are no longer a member of this team (perhaps a new match already started?)

		chosen_class = ctf_gear[choice]

	var/turf/spawn_point = pick(get_adjacent_open_turfs(get_turf(src)))
	var/mob/living/carbon/human/player_mob = new(spawn_point)
	new_team_member.prefs.safe_transfer_prefs_to(player_mob, is_antag = TRUE)
	if(player_mob.dna.species.outfit_important_for_life)

	var/datum/mind/new_member_mind = new_team_member.mob.mind
	if(new_member_mind)
		player_mob.AddComponent( \
			/datum/component/temporary_body, \
			old_mind = new_member_mind, \
			old_body = new_member_mind.current, \
		)

	player_mob.ckey = new_team_member.ckey
	if(isnull(ctf_player_component))
		var/datum/component/ctf_player/player_component = player_mob.mind.AddComponent(/datum/component/ctf_player, team, ctf_game, ammo_type)
		ctf_game.add_player(team, player_mob.ckey, player_component)
	else
		player_mob.mind.TakeComponent(ctf_player_component)
	player_mob.faction += team
	player_mob.equipOutfit(chosen_class)
	player_mob.add_traits(player_traits, CAPTURE_THE_FLAG_TRAIT)
	return player_mob //used in medisim_game.dm

/obj/machinery/ctf/spawner/attackby(obj/item/item, mob/user, list/modifiers, list/attack_modifiers)
	if(istype(item, /obj/item/ctf_flag))
		var/obj/item/ctf_flag/flag = item
		if(flag.team != team)
			ctf_game.capture_flag(team, user, team_span, flag)
			flag.reset_flag(capture = TRUE) //This might be buggy, confirm and fix if it is.

/obj/item/ctf_flag/Initialize(mapload)
	. = ..()
	if(isnull(reset))
		reset = new(get_turf(src))
		reset.flag = src
		reset.icon_state = icon_state
		reset.name = "[name] landmark"
		reset.desc = "This is where \the [name] will respawn in a game of CTF"
	return INITIALIZE_HINT_LATELOAD

/obj/item/ctf_flag/LateInitialize()
	ctf_game = GLOB.ctf_games[game_id] //Flags don't create ctf games by themselves since you can get ctf flags from christmas trees.

/obj/item/ctf_flag/Destroy()
	QDEL_NULL(reset)
	return ..()

/obj/item/ctf_flag/process()
	if(is_ctf_target(loc)) //pickup code calls temporary drops to test things out, we need to make sure the flag doesn't reset from
		return PROCESS_KILL
	if(world.time > reset_cooldown)
		reset_flag()

/obj/item/ctf_flag/proc/reset_flag(capture = FALSE)
	STOP_PROCESSING(SSobj, src)

	var/turf/our_turf = get_turf(src.reset)
	if(!our_turf)
		return TRUE
	forceMove(our_turf)
	if(!capture && !isnull(ctf_game))
		ctf_game.message_all_teams("[src] has been returned to the base!")

//working with attack hand feels like taking my brain and putting it through an industrial pill press so i'm gonna be a bit liberal with the comments //Mood
/obj/item/ctf_flag/attack_hand(mob/living/user, list/modifiers)
	//pre normal check item stuff, this is for our special flag checks
	if(!is_ctf_target(user) && !anyonecanpickup)
		to_chat(user, span_warning("Non-players shouldn't be moving the flag!"))
		return
	if(team in user.faction)
		to_chat(user, span_warning("You can't move your own flag!"))
		return
	if(loc == user)
		if(!user.dropItemToGround(src))
			return
	if(!isnull(ctf_game))
		ctf_game.message_all_teams(span_userdanger("\The [initial(name)] has been taken!"))
	STOP_PROCESSING(SSobj, src)
	anchored = FALSE // Hacky usage that bypasses set_anchored(), because normal checks need this to be FALSE to pass
	. = ..() //this is the actual normal item checks
	if(.) //only apply these flag passives
		anchored = TRUE // Avoid directly assigning to anchored and prefer to use set_anchored() on normal circumstances.
		return
	//passing means the user picked up the flag so we can now apply this
	to_chat(user, span_userdanger("Take \the [initial(name)] to your team's controller!"))
	user.set_anchored(TRUE)
	user.status_flags &= ~CANPUSH

/obj/item/ctf_flag/attackby(obj/item/item, mob/user, list/modifiers, list/attack_modifiers)
	if(!istype(item, /obj/item/ctf_flag))
		return ..()

	var/obj/item/ctf_flag/flag = item
	if(flag.team != team)
		to_chat(user, span_userdanger("Take \the [initial(flag.name)] to your team's controller!"))
		user.playsound_local(get_turf(user), 'sound/machines/buzz/buzz-sigh.ogg', 100, vary = FALSE, use_reverb = FALSE)

/obj/item/ctf_flag/dropped(mob/user)
	..()
	user.anchored = FALSE // Hacky usage that bypasses set_anchored()
	user.status_flags |= CANPUSH
	reset_cooldown = world.time + 20 SECONDS
	START_PROCESSING(SSobj, src)
	if(!isnull(ctf_game))
		ctf_game.message_all_teams(span_userdanger("\The [initial(name)] has been dropped!"))
	anchored = TRUE // Avoid directly assigning to anchored and prefer to use set_anchored() on normal circumstances.

/obj/item/ctf_flag/red
	name = "red flag"
	icon_state = "banner-red"
	inhand_icon_state = "banner-red"
	desc = "A red banner used to play capture the flag."
	team = RED_TEAM

/obj/item/ctf_flag/blue
	name = "blue flag"
	icon_state = "banner-blue"
	inhand_icon_state = "banner-blue"
	desc = "A blue banner used to play capture the flag."
	team = BLUE_TEAM


/obj/item/ctf_flag/red
	name = "Frontiersmen banner"
	icon_state = "banner-frontiersmen"
	item_state = "banner-frontiersmen"
	desc = "The proud banner of the New Frontiersmen. Used as an objective in the C-MM's combat training program."
	team = RED_TEAM

/obj/item/ctf_flag/blue
	name = "Confederated League banner"
	icon_state = "banner-clip"
	item_state = "banner-clip"
	desc = "The proud banner of the Confederated League of Independent Planets. Used as an objective in the C-MM's combat training program."
	team = BLUE_TEAM

/obj/effect/ctf
	density = FALSE
	anchored = TRUE
	invisibility = INVISIBILITY_OBSERVER
	alpha = 100
	resistance_flags = INDESTRUCTIBLE

/obj/effect/ctf/flag_reset
	name = "banner landmark"
	icon = 'icons/obj/banner.dmi'
	icon_state = "banner"
	desc = "This is where a CTF flag will respawn."
	layer = LOW_ITEM_LAYER
	var/obj/item/ctf_flag/flag

/obj/item/ctf_flag/flag_reset/Destroy()
	if(flag)
		flag.reset = null
		flag = null
	return ..()

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

/obj/structure/trap/ctf
	name = "smart mine"
	desc = "An array of color-coded landmines programmed to only detonate on opponents."
	icon = 'icons/obj/landmine.dmi'
	resistance_flags = INDESTRUCTIBLE
	var/team = WHITE_TEAM
	time_between_triggers = 1
	anchored = TRUE
	alpha = 255

/obj/structure/trap/ctf/examine(mob/user)
	return

/obj/structure/trap/ctf/trap_effect(mob/living/L)
	if(!is_ctf_target(L))
		return
	if(!(src.team in L.faction))
		to_chat(L, span_danger("<B>Stay out of the enemy spawn!</B>"))
		L.death()

/obj/structure/trap/ctf/red
	team = RED_TEAM
	icon_state = "mine_armed"

/obj/structure/trap/ctf/blue
	team = BLUE_TEAM
	icon_state = "mine_blue"

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
	desc = "You like revenge, right? Everybody likes revenge! Well, let's go get some!"
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

#define CTF_LOADING_UNLOADED 0
#define CTF_LOADING_LOADING 1
#define CTF_LOADING_LOADED 2

///Proc that handles toggling and unloading CTF.
/proc/toggle_id_ctf(user, activated_id, automated = FALSE, unload = FALSE, area/ctf_area)
	var/static/loading = CTF_LOADING_UNLOADED
	var/datum/ctf_controller/ctf_controller = GLOB.ctf_games[activated_id]
	if(isnull(ctf_controller))
		ctf_controller = create_ctf_game(activated_id)
	if(unload == TRUE)
		log_admin("[key_name_admin(user)] is attempting to unload CTF.")
		message_admins("[key_name_admin(user)] is attempting to unload CTF.")
		if(loading == CTF_LOADING_UNLOADED)
			to_chat(user, span_warning("CTF cannot be unloaded if it was not loaded in the first place!"))
			return
		to_chat(user, span_warning("CTF is being unloaded!"))
		ctf_controller.unload_ctf()
		log_admin("[key_name_admin(user)] has unloaded CTF.")
		message_admins("[key_name_admin(user)] has unloaded CTF.")
		loading = CTF_LOADING_UNLOADED
		return
	switch (loading)
		if (CTF_LOADING_UNLOADED)
			if (isnull(GLOB.ctf_spawner))
				to_chat(user, span_boldwarning("Couldn't find a CTF spawner. Call a maintainer!"))
				return

			to_chat(user, span_notice("Loading CTF..."))

			loading = CTF_LOADING_LOADING
			if(activated_id == CTF_GHOST_CTF_GAME_ID) //Only ghost CTF supports map loading, if CTF is started by an admin elsewhere the map loader should not be used.
				if(!GLOB.ctf_spawner.load_map(user))
					to_chat(user, span_warning("CTF loading was cancelled"))
					loading = CTF_LOADING_UNLOADED
					return
			loading = CTF_LOADING_LOADED
		if (CTF_LOADING_LOADING)
			to_chat(user, span_warning("CTF is loading!"))

			return

	var/ctf_enabled = FALSE
	ctf_enabled = ctf_controller.toggle_ctf()
	for(var/turf/ctf_turf as anything in get_area_turfs(ctf_area))
		for(var/obj/machinery/power/emitter/emitter in ctf_turf)
			emitter.active = ctf_enabled
	if(user)
		message_admins("[key_name_admin(user)] has [ctf_enabled ? "enabled" : "disabled"] CTF!")
	else if(automated)
		message_admins("CTF has finished a round and automatically restarted.")
		notify_ghosts(
			"CTF has automatically restarted after a round finished in [initial(ctf_area.name)]!",
			ghost_sound = 'sound/effects/ghost2.ogg',
			header = "CTF Restarted"
		)
	else
		message_admins("The players have spoken! Voting has enabled CTF!")
	if(!automated)
		notify_ghosts(
			"CTF has been [ctf_enabled? "enabled" : "disabled"] in [initial(ctf_area.name)]!",
			ghost_sound = 'sound/effects/ghost2.ogg',
			header = "CTF [ctf_enabled? "Enabled" : "Disabled"]"
		)

#undef CTF_LOADING_UNLOADED
#undef CTF_LOADING_LOADING
#undef CTF_LOADING_LOADED

///Proc that identifies if something is a valid target for CTF related checks, checks if an object is a ctf barrier or has ctf component if they are a player.
/proc/is_ctf_target(atom/target)
	if(istype(target, /obj/structure/barricade/security/ctf))
		return TRUE
	if(ishuman(target))
		var/mob/living/carbon/human/human = target
		if(human.mind?.GetComponent(/datum/component/ctf_player))
			return TRUE
	return FALSE

#undef WHITE_TEAM
#undef RED_TEAM
#undef BLUE_TEAM
#undef FLAG_RETURN_TIME
