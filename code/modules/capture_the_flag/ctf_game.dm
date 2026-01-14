#define WHITE_TEAM "White"
#define RED_TEAM "Frontiersmen"
#define BLUE_TEAM "CLIP"
#define FLAG_RETURN_TIME 20 SECONDS
#define AMMO_DROP_LIFETIME 300

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
	var/player_traits = list()
	var/list/spawned_mobs = list()

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
		"Rifleman" = /datum/outfit/ctf/frontiersmen/rifleman,
		"Engineer" = /datum/outfit/ctf/frontiersmen/engineer,
		"Marksman" = /datum/outfit/ctf/frontiersmen/marksman,
		"Medic" = /datum/outfit/ctf/frontiersmen/medic,
		"Breacher" = /datum/outfit/ctf/frontiersmen/breacher,
		"Specialist" = /datum/outfit/ctf/frontiersmen/specialist
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
		if(!choice || !isobserver(new_team_member.mob) || ctf_game.ctf_enabled == FALSE || !(new_team_member.ckey in ctf_game.get_players(team)))
			return //picked nothing, admin disabled it, cheating to respawn faster, cheating to respawn... while in game?,
					//there isn't a game going on any more, you are no longer a member of this team (perhaps a new match already started?)

		chosen_class = ctf_gear[choice]

	var/turf/spawn_point = pick(get_adjacent_open_turfs(get_turf(src)))
	var/mob/living/carbon/human/player_mob = new(spawn_point)
	new_team_member.prefs.copy_to(player_mob)

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

/obj/item/ctf_flag
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
	resistance_flags = INDESTRUCTIBLE | LAVA_PROOF | FIRE_PROOF | UNACIDABLE | ACID_PROOF
	anchored = TRUE
	item_flags = SLOWS_WHILE_IN_HAND
	///Team that this flag is associated with, a team cannot capture its own flag.
	var/team = WHITE_TEAM
	///Var used for tracking when this flag should be returned to base.
	var/reset_cooldown = 0
	///Can anyone pick up the flag or only players of the opposing team.
	var/anyonecanpickup = TRUE
	///Reference to an object that's location is used when this flag needs to respawn.
	var/obj/effect/ctf/flag_reset/reset
	///Game_id that this flag is associated with.
	var/game_id = CTF_GHOST_CTF_GAME_ID
	///Reference to the CTF controller associated with the above game ID.
	var/datum/ctf_controller/ctf_game
	///How many points this flag is worth when captured.
	var/flag_value = 1

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
		user.playsound_local(get_turf(user), 'sound/machines/buzz-sigh.ogg', 100, vary = FALSE, use_reverb = FALSE)

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
	name = "\improper Frontiersmen banner"
	icon_state = "banner-frontiersmen"
	item_state = "banner-frontiersmen"
	desc = "The proud banner of the New Frontiersmen. Used as an objective in the C-MM's combat training program."
	team = RED_TEAM

/obj/item/ctf_flag/blue
	name = "\improper Confederated League banner"
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

/obj/effect/ctf/flag_reset/Destroy()
	if(flag)
		flag.reset = null
		flag = null
	return ..()

/obj/structure/trap/ctf
	name = "smart mine"
	desc = "An array of color-coded landmines programmed to only detonate on opponents."
	icon = 'icons/obj/landmine.dmi'
	resistance_flags = INDESTRUCTIBLE
	var/team = WHITE_TEAM
	time_between_triggers = 1
	anchored = TRUE
	alpha = 255

/obj/structure/trap/ctf/trap_effect(mob/living/living)
	if(!is_ctf_target(living))
		return
	if(!(src.team in living.faction))
		to_chat(living, span_bolddanger("Stay out of the enemy spawn!"))
		living.investigate_log("has died from entering the enemy spawn in CTF.")
		living.apply_damage(200) //Damage instead of instant death so we trigger the damage signal.

/obj/structure/trap/ctf/red
	team = RED_TEAM
	icon_state = "mine_armed"

/obj/structure/trap/ctf/blue
	team = BLUE_TEAM
	icon_state = "mine_blue"

///A type of barricade that can be destroyed by CTF weapons and respawns at the end of CTF matches.
/obj/structure/barricade/security/ctf
	name = "barrier"
	desc = "A barrier. Provides cover in fire fights."

/obj/structure/barricade/security/ctf/make_debris()
	new /obj/effect/ctf/dead_barricade(get_turf(src))

/obj/effect/ctf/dead_barricade
	name = "dead barrier"
	desc = "It provided cover in fire fights. And now it's gone."
	icon = 'icons/obj/structures.dmi'
	icon_state = "barrier0"
	var/game_id = CTF_GHOST_CTF_GAME_ID
	var/datum/ctf_controller/ctf_game

/obj/effect/ctf/dead_barricade/Initialize(mapload)
	. = ..()
	ctf_game = GLOB.ctf_games[game_id]
	ctf_game.barricades += src

/obj/effect/ctf/dead_barricade/Destroy()
	ctf_game.barricades -= src
	return ..()

/obj/effect/ctf/dead_barricade/proc/respawn()
	if(!QDELETED(src))
		new /obj/structure/barricade/security/ctf(get_turf(src))
		qdel(src)

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
	for(var/obj/machinery/ctf/spawner/CTF in GLOB.machines)
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

///Control point used for CTF for king of the hill or control point game modes. Teams need to maintain control of the point for a set time to win.
/obj/machinery/ctf/control_point
	name = "control point"
	desc = "You should capture this"
	icon = 'icons/obj/machines/dominator.dmi'
	icon_state = "dominator"
	///Team that is currently controlling this point.
	var/controlling_team
	///Amount of points generated per second by this control point while captured.
	var/point_rate = 1

/obj/machinery/ctf/control_point/Initialize(mapload)
	. = ..()
	ctf_game.control_points += src

/obj/machinery/ctf/control_point/Destroy()
	ctf_game.control_points.Remove(src)
	return ..()

/obj/machinery/ctf/control_point/process(seconds_per_tick)
	if(controlling_team)
		ctf_game.control_point_scoring(controlling_team, point_rate * seconds_per_tick)

	var/scores

	if(ctf_game.ctf_enabled)
		for(var/team in ctf_game.teams)
			var/datum/ctf_team/ctf_team = ctf_game.teams[team]
			scores += UNLINT("<span style='color: [ctf_team.team_color]'>[ctf_team.team_color] - [ctf_team.points]/[ctf_game.points_to_win]</span>\n")
		balloon_alert_to_viewers(scores)

/obj/machinery/ctf/control_point/attackby(obj/item/item, mob/user, list/modifiers, list/attack_modifiers)
	capture(user)

/obj/machinery/ctf/control_point/attack_hand(mob/user, list/modifiers)
	. = ..()
	if(.)
		return
	capture(user)

///Proc called when a player interacts with the control point to handle capturing it. Performs a do after and then verifies what team ther capturer belongs to.
/obj/machinery/ctf/control_point/proc/capture(mob/user)
	if(do_after(user, 3 SECONDS, target = src))
		var/datum/component/ctf_player/ctf_player = user.mind.GetComponent(/datum/component/ctf_player)
		if(isnull(ctf_player))
			to_chat(user, span_warning("Non-players shouldn't be capturing control points"))
			return
		controlling_team = ctf_player.team
		icon_state = "dominator-[controlling_team]"
		ctf_game.message_all_teams("<span class='userdanger [ctf_game.teams[controlling_team].team_span]'>[user.real_name] has captured \the [src], claiming it for [controlling_team]! Go take it back!</span>")

/obj/machinery/ctf/control_point/proc/clear_point()
	controlling_team = null
	icon_state = "dominator"

///Proc that handles toggling and unloading CTF.
/proc/toggle_id_ctf(user, activated_id, automated = FALSE, unload = FALSE, area/ctf_area)
	var/datum/ctf_controller/ctf_controller = GLOB.ctf_games[activated_id]
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

///Proc that identifies if something is a valid target for CTF related checks, checks if an object is a ctf barrier or has ctf component if they are a player.
/proc/is_ctf_target(atom/target)
	if(istype(target, /obj/structure/barricade/security/ctf))
		return TRUE
	if(ishuman(target))
		var/mob/living/carbon/human/human = target
		if(human.mind?.GetComponent(/datum/component/ctf_player))
			return TRUE
	return FALSE

#undef AMMO_DROP_LIFETIME
#undef WHITE_TEAM
#undef RED_TEAM
#undef BLUE_TEAM
#undef FLAG_RETURN_TIME
