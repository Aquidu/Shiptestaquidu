#define SPIDER_IDLE 0
#define SPINNING_WEB 1
#define LAYING_EGGS 2
#define MOVING_TO_TARGET 3
#define SPINNING_COCOON 4

/mob/living/simple_animal/hostile/poison
	var/poison_per_bite = 5
	var/poison_type = /datum/reagent/toxin

/mob/living/simple_animal/hostile/poison/AttackingTarget()
	. = ..()
	if(.)
		inject_poison(target)

/// Handles injecting the poison after successful attack
/mob/living/simple_animal/hostile/poison/proc/inject_poison(mob/living/L)
	if(poison_type && istype(L) && L.reagents)
		L.reagents.add_reagent(poison_type, poison_per_bite)

//basic spider mob, these generally guard nests
/mob/living/simple_animal/hostile/poison/giant_spider
	name = "giant spider"
	desc = "Furry and black, it makes you shudder to look at it. This one has deep red eyes."
	icon_state = "guard"
	icon_living = "guard"
	icon_dead = "guard_dead"
	mob_biotypes = MOB_ORGANIC|MOB_BUG
	speak_emote = list("chitters")
	emote_hear = list("chitters")
	speak_chance = 5
	turns_per_move = 5
	see_in_dark = 4
	butcher_results = list(/obj/item/food/meat/slab/spider = 2, /obj/item/food/spiderleg = 8)
	response_help_continuous = "pets"
	response_help_simple = "pet"
	response_disarm_continuous = "gently pushes aside"
	response_disarm_simple = "gently push aside"
	maxHealth = 60
	health = 60
	obj_damage = 60
	melee_damage_lower = 5
	melee_damage_upper = 15
	faction = list("spiders")
	var/busy = SPIDER_IDLE
	pass_flags = PASSTABLE
	move_to_delay = 6
	ventcrawler = VENTCRAWLER_ALWAYS
	attack_verb_continuous = "bites"
	attack_verb_simple = "bite"
	attack_sound = 'sound/weapons/bite.ogg'
	lighting_alpha = LIGHTING_PLANE_ALPHA_MOSTLY_VISIBLE
	footstep_type = FOOTSTEP_MOB_CLAW
	sharpness = SHARP_POINTY
	mob_size = MOB_SIZE_LARGE
	var/playable_spider = FALSE
	var/datum/action/innate/spider/lay_web/lay_web
	var/directive = "" //Message passed down to children, to relay the creator's orders

/mob/living/simple_animal/hostile/poison/giant_spider/Initialize()
	. = ..()
	lay_web = new
	lay_web.Grant(src)

/mob/living/simple_animal/hostile/poison/giant_spider/Destroy()
	QDEL_NULL(lay_web)
	return ..()

/mob/living/simple_animal/hostile/poison/giant_spider/Topic(href, href_list)
	if(href_list["activate"])
		var/mob/dead/observer/ghost = usr
		if(istype(ghost) && playable_spider)
			humanize_spider(ghost)

/mob/living/simple_animal/hostile/poison/giant_spider/Login()
	. = ..()
	if(!. || !client)
		return FALSE
	if(directive)
		to_chat(src, span_spider("Your mother left you a directive! Follow it at all costs."))
		to_chat(src, span_spider("<b>[directive]</b>"))
		if(mind)
			mind.store_memory(span_spider("<b>[directive]</b>"))

/mob/living/simple_animal/hostile/poison/giant_spider/proc/humanize_spider(mob/user)
	if(key || !playable_spider || stat)//Someone is in it, it's dead, or the fun police are shutting it down
		return 0
	var/spider_ask = alert("Become a spider?", "Are you australian?", "Yes", "No")
	if(spider_ask == "No" || !src || QDELETED(src))
		return 1
	if(key)
		to_chat(user, span_warning("Someone else already took this spider!"))
		return 1
	key = user.key
	if(directive)
		log_game("[key_name(src)] took control of [name] with the objective: '[directive]'.")
	return 1

//nursemaids - these create webs and eggs
/mob/living/simple_animal/hostile/poison/giant_spider/nurse
	desc = "Furry and black, it makes you shudder to look at it. This one has brilliant green eyes."
	icon_state = "nurse"
	icon_living = "nurse"
	icon_dead = "nurse_dead"
	gender = FEMALE
	butcher_results = list(/obj/item/food/meat/slab/spider = 2, /obj/item/food/spiderleg = 8, /obj/item/food/spidereggs = 4)
	maxHealth = 40
	health = 40
	melee_damage_lower = 5
	melee_damage_upper = 10
	poison_per_bite = 3
	var/datum/weakref/cocoon_target_ref
	var/fed = 0
	var/obj/effect/proc_holder/wrap/wrap
	var/datum/action/innate/spider/lay_eggs/lay_eggs
	var/datum/action/innate/spider/set_directive/set_directive
	var/static/list/consumed_mobs = list() //the refs of mobs that have been consumed by nurse spiders to lay eggs

/mob/living/simple_animal/hostile/poison/giant_spider/nurse/Initialize()
	. = ..()
	wrap = new
	AddAbility(wrap)
	lay_eggs = new
	lay_eggs.Grant(src)
	set_directive = new
	set_directive.Grant(src)

/mob/living/simple_animal/hostile/poison/giant_spider/nurse/Destroy()
	RemoveAbility(wrap)
	QDEL_NULL(lay_eggs)
	QDEL_NULL(set_directive)
	QDEL_NULL(wrap)
	return ..()

//broodmothers are the queen of the spiders, can send messages to all them and web faster. That rare round where you get a queen spider and turn your 'for honor' players into 'r6siege' players will be a fun one.
/mob/living/simple_animal/hostile/poison/giant_spider/nurse/midwife
	name = "broodmother"
	desc = "Furry and black, it makes you shudder to look at it. This one has scintillating green eyes. Might also be hiding a real knife somewhere."
	icon_state = "midwife"
	icon_living = "midwife"
	icon_dead = "midwife_dead"
	maxHealth = 40
	health = 40
	var/datum/action/innate/spider/comm/letmetalkpls

/mob/living/simple_animal/hostile/poison/giant_spider/nurse/midwife/Initialize()
	. = ..()
	letmetalkpls = new
	letmetalkpls.Grant(src)

/mob/living/simple_animal/hostile/poison/giant_spider/nurse/midwife/Destroy()
	QDEL_NULL(letmetalkpls)
	return ..()

//hunters have the most poison and move the fastest, so they can find prey
/mob/living/simple_animal/hostile/poison/giant_spider/hunter
	desc = "Furry and black, it makes you shudder to look at it. This one has sparkling purple eyes."
	icon_state = "hunter"
	icon_living = "hunter"
	icon_dead = "hunter_dead"
	maxHealth = 50
	health = 50
	melee_damage_lower = 10
	melee_damage_upper = 20
	poison_per_bite = 5
	move_to_delay = 5

//vipers are the rare variant of the hunter, no IMMEDIATE damage but so much poison medical care will be needed fast.
/mob/living/simple_animal/hostile/poison/giant_spider/hunter/viper
	name = "viper"
	desc = "Furry and black, it makes you shudder to look at it. This one has effervescent purple eyes."
	icon_state = "viper"
	icon_living = "viper"
	icon_dead = "viper_dead"
	maxHealth = 25
	health = 25
	melee_damage_lower = 3
	melee_damage_upper = 8
	poison_per_bite = 2
	move_to_delay = 4
	poison_type = /datum/reagent/toxin/venom //all in venom, glass cannon. you bite 5 times and they are DEFINITELY dead, but 40 health and you are extremely obvious. Ambush, maybe?
	speed = 1

//tarantulas are really tanky, regenerating (maybe), hulky monster but are also extremely slow, so.
/mob/living/simple_animal/hostile/poison/giant_spider/tarantula
	name = "tarantula"
	desc = "Furry and black, it makes you shudder to look at it. This one has abyssal red eyes."
	icon_state = "tarantula"
	icon_living = "tarantula"
	icon_dead = "tarantula_dead"
	maxHealth = 50 // woah nelly
	health = 50
	melee_damage_lower = 15
	melee_damage_upper = 20
	poison_per_bite = 0
	move_to_delay = 8
	speed = 9
	status_flags = NONE
	var/slowed_by_webs = FALSE

/mob/living/simple_animal/hostile/poison/giant_spider/tarantula/Moved(atom/oldloc, dir)
	. = ..()
	if(slowed_by_webs)
		if(!(locate(/obj/structure/spider/stickyweb) in loc))
			remove_movespeed_modifier(/datum/movespeed_modifier/tarantula_web)
			slowed_by_webs = FALSE
	else if(locate(/obj/structure/spider/stickyweb) in loc)
		add_movespeed_modifier(/datum/movespeed_modifier/tarantula_web)
		slowed_by_webs = TRUE

/mob/living/simple_animal/hostile/poison/giant_spider/ice //spiders dont usually like tempatures of 140 kelvin who knew
	name = "giant ice spider"
	atmos_requirements = IMMUNE_ATMOS_REQS
	minbodytemp = 0
	maxbodytemp = 1500
	poison_type = /datum/reagent/consumable/frostoil
	color = rgb(114,228,250)

/mob/living/simple_animal/hostile/poison/giant_spider/nurse/ice
	name = "giant ice spider"
	atmos_requirements = IMMUNE_ATMOS_REQS
	minbodytemp = 0
	maxbodytemp = 1500
	poison_type = /datum/reagent/consumable/frostoil
	color = rgb(114,228,250)

/mob/living/simple_animal/hostile/poison/giant_spider/hunter/ice
	name = "giant ice spider"
	atmos_requirements = IMMUNE_ATMOS_REQS
	minbodytemp = 0
	maxbodytemp = 1500
	poison_type = /datum/reagent/consumable/frostoil
	color = rgb(114,228,250)

/mob/living/simple_animal/hostile/poison/giant_spider/handle_automated_action()
	if(!..()) //AIStatus is off
		return 0
	if(AIStatus == AI_IDLE)
		//1% chance to skitter madly away
		if(!busy && prob(1))
			stop_automated_movement = TRUE
			Goto(pick(urange(20, src, 1)), move_to_delay)
			addtimer(CALLBACK(src, PROC_REF(do_action)), 5 SECONDS)
		return 1

/mob/living/simple_animal/hostile/poison/giant_spider/proc/do_action()
	stop_automated_movement = FALSE
	walk(src,0)

/mob/living/simple_animal/hostile/poison/giant_spider/nurse/proc/GiveUp(mob/living/target)
	if(busy == MOVING_TO_TARGET)
		if(cocoon_target_ref == WEAKREF(target) && get_dist(src, target) > 1)
			cocoon_target_ref = null
		busy = FALSE
		stop_automated_movement = FALSE

/mob/living/simple_animal/hostile/poison/giant_spider/nurse/handle_automated_action()
	if(..())
		var/list/can_see = view(src, 10)
		if(!busy && prob(30))	//30% chance to stop wandering and do something
			//first, check for potential food nearby to cocoon
			for(var/mob/living/C in can_see)
				if(C.stat && !istype(C, /mob/living/simple_animal/hostile/poison/giant_spider) && !C.anchored)
					cocoon_target_ref = WEAKREF(C)
					busy = MOVING_TO_TARGET
					Goto(C, move_to_delay)
					//give up if we can't reach them after 10 seconds
					addtimer(CALLBACK(src, PROC_REF(GiveUp), C), 10 SECONDS)
					return

			//second, spin a sticky spiderweb on this tile
			var/obj/structure/spider/stickyweb/W = locate() in get_turf(src)
			if(!W)
				lay_web.Activate()
			else
				//third, lay an egg cluster there
				if(fed)
					lay_eggs.Activate()
				else
					//fourthly, cocoon any nearby items so those pesky pinkskins can't use them
					for(var/obj/O in can_see)

						if(O.anchored)
							continue

						if(isitem(O) || isstructure(O) || ismachinery(O))
							cocoon_target_ref = WEAKREF(O)
							busy = MOVING_TO_TARGET
							stop_automated_movement = 1
							Goto(O, move_to_delay)
							//give up if we can't reach them after 10 seconds
							addtimer(CALLBACK(src, PROC_REF(GiveUp), O), 10 SECONDS)

		else if(busy == MOVING_TO_TARGET && cocoon_target_ref)
			var/mob/living/cocoon_target = cocoon_target_ref.resolve()
			if(!cocoon_target)
				return
			if(get_dist(src, cocoon_target) <= 1)
				cocoon()

	else
		busy = SPIDER_IDLE
		stop_automated_movement = FALSE

/mob/living/simple_animal/hostile/poison/giant_spider/nurse/proc/cocoon()
	var/mob/living/cocoon_target = cocoon_target_ref?.resolve()
	if(stat != DEAD && cocoon_target && !cocoon_target.anchored)
		if(cocoon_target == src)
			to_chat(src, span_warning("You can't wrap yourself!"))
			return
		if(istype(cocoon_target, /mob/living/simple_animal/hostile/poison/giant_spider))
			to_chat(src, span_warning("You can't wrap other spiders!"))
			return
		if(!Adjacent(cocoon_target))
			to_chat(src, span_warning("You can't reach [cocoon_target]!"))
			return
		if(busy == SPINNING_COCOON)
			to_chat(src, span_warning("You're already spinning a cocoon!"))
			return //we're already doing this, don't cancel out or anything
		busy = SPINNING_COCOON
		visible_message(span_notice("[src] begins to secrete a sticky substance around [cocoon_target]."),span_notice("You begin wrapping [cocoon_target] into a cocoon."))
		stop_automated_movement = TRUE
		walk(src,0)
		if(do_after(src, 50, target = cocoon_target))
			if(busy == SPINNING_COCOON)
				var/obj/structure/spider/cocoon/C = new(cocoon_target.loc)
				if(isliving(cocoon_target))
					var/mob/living/L = cocoon_target
					if(L.blood_volume && (L.stat != DEAD || !consumed_mobs[REF(L)])) //if they're not dead, you can consume them anyway
						consumed_mobs[REF(L)] = TRUE
						fed++
						lay_eggs.UpdateButtonIcon(TRUE)
						visible_message(span_danger("[src] sticks a proboscis into [L] and sucks a viscous substance out."),span_notice("You suck the nutriment out of [L], feeding you enough to lay a cluster of eggs."))
						L.death() //you just ate them, they're dead.
					else
						to_chat(src, span_warning("[L] cannot sate your hunger!"))
				cocoon_target.forceMove(C)

				if(cocoon_target.density || ismob(cocoon_target))
					C.icon_state = pick("cocoon_large1","cocoon_large2","cocoon_large3")
	cocoon_target = null
	busy = SPIDER_IDLE
	stop_automated_movement = FALSE

/datum/action/innate/spider
	icon_icon = 'icons/mob/actions/actions_animal.dmi'
	background_icon_state = "bg_alien"

/datum/action/innate/spider/lay_web
	name = "Spin Web"
	desc = "Spin a web to slow down potential prey."
	check_flags = AB_CHECK_CONSCIOUS
	button_icon_state = "lay_web"

/datum/action/innate/spider/lay_web/Activate()
	if(!istype(owner, /mob/living/simple_animal/hostile/poison/giant_spider))
		return
	var/mob/living/simple_animal/hostile/poison/giant_spider/S = owner

	if(!isturf(S.loc))
		return
	var/turf/T = get_turf(S)

	var/obj/structure/spider/stickyweb/W = locate() in T
	if(W)
		to_chat(S, span_warning("There's already a web here!"))
		return

	if(S.busy != SPINNING_WEB)
		S.busy = SPINNING_WEB
		S.visible_message(span_notice("[S] begins to secrete a sticky substance."),span_notice("You begin to lay a web."))
		S.stop_automated_movement = TRUE
		if(do_after(S, 40, target = T))
			if(S.busy == SPINNING_WEB && S.loc == T)
				new /obj/structure/spider/stickyweb(T)
		S.busy = SPIDER_IDLE
		S.stop_automated_movement = FALSE
	else
		to_chat(S, span_warning("You're already spinning a web!"))

/obj/effect/proc_holder/wrap
	name = "Wrap"
	panel = "Spider"
	active = FALSE
	action = null
	desc = "Wrap something or someone in a cocoon. If it's a living being, you'll also consume them, allowing you to lay eggs."
	ranged_mousepointer = 'icons/effects/mouse_pointers/wrap_target.dmi'
	action_icon = 'icons/mob/actions/actions_animal.dmi'
	action_icon_state = "wrap_0"
	action_background_icon_state = "bg_alien"
	//Set this to false since we're our own action, for some reason
	has_action = FALSE

/obj/effect/proc_holder/wrap/Initialize()
	. = ..()
	action = new(src)

/obj/effect/proc_holder/wrap/update_icon()
	action.button_icon_state = "wrap_[active]"
	action.UpdateButtonIcon()
	return ..()

/obj/effect/proc_holder/wrap/Click()
	if(!istype(usr, /mob/living/simple_animal/hostile/poison/giant_spider/nurse))
		return TRUE
	var/mob/living/simple_animal/hostile/poison/giant_spider/nurse/user = usr
	activate(user)
	return TRUE

/obj/effect/proc_holder/wrap/proc/activate(mob/living/user)
	var/message
	if(active)
		message = span_notice("You no longer prepare to wrap something in a cocoon.")
		remove_ranged_ability(message)
	else
		message = span_notice("You prepare to wrap something in a cocoon. <B>Left-click your target to start wrapping!</B>")
		add_ranged_ability(user, message, TRUE)
		return 1

/obj/effect/proc_holder/wrap/InterceptClickOn(mob/living/clicker, params, atom/target)
	if(..())
		return
	if(ranged_ability_user.incapacitated() || !istype(ranged_ability_user, /mob/living/simple_animal/hostile/poison/giant_spider/nurse))
		remove_ranged_ability()
		return

	var/mob/living/simple_animal/hostile/poison/giant_spider/nurse/user = ranged_ability_user

	if(user.Adjacent(target) && (ismob(target) || isobj(target)))
		var/atom/movable/target_atom = target
		if(target_atom.anchored)
			return
		user.cocoon_target_ref = WEAKREF(target_atom)
		INVOKE_ASYNC(user, TYPE_PROC_REF(/mob/living/simple_animal/hostile/poison/giant_spider/nurse, cocoon))
		remove_ranged_ability()
		return TRUE

/obj/effect/proc_holder/wrap/on_lose(mob/living/carbon/user)
	remove_ranged_ability()

/datum/action/innate/spider/lay_eggs
	name = "Lay Eggs"
	desc = "Lay a cluster of eggs, which will soon grow into more spiders. You must wrap a living being to do this."
	check_flags = AB_CHECK_CONSCIOUS
	button_icon_state = "lay_eggs"

/datum/action/innate/spider/lay_eggs/IsAvailable()
	if(..())
		if(!istype(owner, /mob/living/simple_animal/hostile/poison/giant_spider/nurse))
			return 0
		var/mob/living/simple_animal/hostile/poison/giant_spider/nurse/S = owner
		if(S.fed)
			return 1
		return 0

/datum/action/innate/spider/lay_eggs/Activate()
	if(!istype(owner, /mob/living/simple_animal/hostile/poison/giant_spider/nurse))
		return
	var/mob/living/simple_animal/hostile/poison/giant_spider/nurse/S = owner

	var/obj/structure/spider/eggcluster/E = locate() in get_turf(S)
	if(E)
		to_chat(S, span_warning("There is already a cluster of eggs here!"))
	else if(!S.fed)
		to_chat(S, span_warning("You are too hungry to do this!"))
	else if(S.busy != LAYING_EGGS)
		S.busy = LAYING_EGGS
		S.visible_message(span_notice("[S] begins to lay a cluster of eggs."),span_notice("You begin to lay a cluster of eggs."))
		S.stop_automated_movement = TRUE
		if(do_after(S, 50, target = get_turf(S)))
			if(S.busy == LAYING_EGGS)
				E = locate() in get_turf(S)
				if(!E || !isturf(S.loc))
					var/obj/structure/spider/eggcluster/C = new /obj/structure/spider/eggcluster(get_turf(S))
					if(S.ckey)
						C.player_spiders = TRUE
					C.directive = S.directive
					C.poison_type = S.poison_type
					C.poison_per_bite = S.poison_per_bite
					C.faction = S.faction.Copy()
					S.fed--
					UpdateButtonIcon(TRUE)
		S.busy = SPIDER_IDLE
		S.stop_automated_movement = FALSE

/datum/action/innate/spider/set_directive
	name = "Set Directive"
	desc = "Set a directive for your children to follow."
	check_flags = AB_CHECK_CONSCIOUS
	button_icon_state = "directive"

/datum/action/innate/spider/set_directive/IsAvailable()
	if(..())
		if(!istype(owner, /mob/living/simple_animal/hostile/poison/giant_spider))
			return FALSE
		var/mob/living/simple_animal/hostile/poison/giant_spider/S = owner
		if(S.playable_spider)
			return FALSE
		return TRUE

/datum/action/innate/spider/set_directive/Activate()
	if(!istype(owner, /mob/living/simple_animal/hostile/poison/giant_spider/nurse))
		return
	var/mob/living/simple_animal/hostile/poison/giant_spider/nurse/S = owner
	if(!S.playable_spider)
		S.directive = stripped_input(S, "Enter the new directive", "Create directive", "[S.directive]")
		message_admins("[ADMIN_LOOKUPFLW(owner)] set its directive to: '[S.directive]'.")
		log_game("[key_name(owner)] set its directive to: '[S.directive]'.")

/mob/living/simple_animal/hostile/poison/giant_spider/Login()
	. = ..()
	if(!. || !client)
		return FALSE
	GLOB.spidermobs[src] = TRUE

/mob/living/simple_animal/hostile/poison/giant_spider/Destroy()
	GLOB.spidermobs -= src
	return ..()

/datum/action/innate/spider/comm
	name = "Command"
	desc = "Send a command to all living spiders."
	button_icon_state = "command"

/datum/action/innate/spider/comm/IsAvailable()
	if(!istype(owner, /mob/living/simple_animal/hostile/poison/giant_spider/nurse/midwife))
		return FALSE
	return TRUE

/datum/action/innate/spider/comm/Trigger()
	var/input = stripped_input(owner, "Input a command for your legions to follow.", "Command", "")
	if(QDELETED(src) || !input || !IsAvailable())
		return FALSE
	spider_command(owner, input)
	return TRUE

/datum/action/innate/spider/comm/proc/spider_command(mob/living/user, message)
	if(!message)
		return
	var/my_message
	my_message = span_spider("<b>Command from [user]:</b> [message]")
	for(var/mob/living/simple_animal/hostile/poison/giant_spider/M in GLOB.spidermobs)
		to_chat(M, my_message)
	for(var/M in GLOB.dead_mob_list)
		var/link = FOLLOW_LINK(M, user)
		to_chat(M, "[link] [my_message]")
	usr.log_talk(message, LOG_SAY, tag="spider command")

/mob/living/simple_animal/hostile/poison/giant_spider/handle_temperature_damage()
	if(bodytemperature < minbodytemp)
		adjustBruteLoss(20)
		throw_alert("temp", /atom/movable/screen/alert/cold, 3)
	else if(bodytemperature > maxbodytemp)
		adjustBruteLoss(20)
		throw_alert("temp", /atom/movable/screen/alert/hot, 3)
	else
		clear_alert("temp")

#undef SPIDER_IDLE
#undef SPINNING_WEB
#undef LAYING_EGGS
#undef MOVING_TO_TARGET
#undef SPINNING_COCOON
