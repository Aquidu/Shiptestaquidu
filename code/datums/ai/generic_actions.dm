
/datum/ai_behavior/resist/perform(seconds_per_tick, datum/ai_controller/controller)
	. = ..()
	var/mob/living/living_pawn = controller.pawn
	living_pawn.resist()
	finish_action(controller, TRUE)

/datum/ai_behavior/battle_screech
	///List of possible screeches the behavior has
	var/list/screeches

/datum/ai_behavior/battle_screech/perform(seconds_per_tick, datum/ai_controller/controller)
	. = ..()
	var/mob/living/living_pawn = controller.pawn
	INVOKE_ASYNC(living_pawn, TYPE_PROC_REF(/mob, emote), pick(screeches))
	finish_action(controller, TRUE)

///Moves to target then finishes
/datum/ai_behavior/move_to_target
	behavior_flags = AI_BEHAVIOR_REQUIRE_MOVEMENT

/datum/ai_behavior/move_to_target/perform(seconds_per_tick, datum/ai_controller/controller)
	. = ..()
	finish_action(controller, TRUE)


/// Use in hand the currently held item
/datum/ai_behavior/use_in_hand
	behavior_flags = AI_BEHAVIOR_MOVE_AND_PERFORM

/datum/ai_behavior/use_in_hand/perform(seconds_per_tick, datum/ai_controller/controller)
	. = ..()
	var/mob/living/pawn = controller.pawn
	var/obj/item/held = pawn.get_item_by_slot(pawn.get_active_hand())
	if(!held)
		finish_action(controller, FALSE)
		return
	pawn.activate_hand(pawn.get_active_hand())
	finish_action(controller, TRUE)

/// Use the currently held item, or unarmed, on an object in the world
/datum/ai_behavior/use_on_object
	required_distance = 1
	behavior_flags = AI_BEHAVIOR_REQUIRE_MOVEMENT

/datum/ai_behavior/use_on_object/setup(datum/ai_controller/controller, target_key)
	. = ..()
	controller.current_movement_target = controller.blackboard[target_key]

/datum/ai_behavior/use_on_object/perform(seconds_per_tick, datum/ai_controller/controller, target_key)
	. = ..()
	var/mob/living/pawn = controller.pawn
	var/obj/item/held_item = pawn.get_item_by_slot(pawn.get_active_hand())
	var/atom/target = controller.blackboard[BB_MONKEY_CURRENT_PRESS_TARGET]

	if(!target || !pawn.CanReach(target))
		finish_action(controller, FALSE)
		return

	pawn.a_intent = INTENT_HELP
	if(held_item)
		held_item.melee_attack_chain(pawn, target)
	else
		pawn.UnarmedAttack(target, TRUE)

	finish_action(controller, TRUE)

/datum/ai_behavior/give
	required_distance = 1
	behavior_flags = AI_BEHAVIOR_REQUIRE_MOVEMENT


/datum/ai_behavior/give/setup(datum/ai_controller/controller, target_key)
	. = ..()
	controller.current_movement_target = controller.blackboard[target_key]


/datum/ai_behavior/give/perform(seconds_per_tick, datum/ai_controller/controller, target_key)
	. = ..()
	var/mob/living/pawn = controller.pawn
	var/obj/item/held_item = pawn.get_item_by_slot(pawn.get_active_hand())
	var/atom/target = controller.blackboard[target_key]

	if(!target || !pawn.CanReach(target) || !isliving(target))
		finish_action(controller, FALSE)
		return

	var/mob/living/living_target = target
	controller.PauseAi(1.5 SECONDS)
	living_target.visible_message(
		span_info("[pawn] starts trying to give [held_item] to [living_target]!"),
		span_warning("[pawn] tries to give you [held_item]!")
	)
	if(!do_after(pawn, 1 SECONDS, living_target))
		return
	if(QDELETED(held_item) || QDELETED(living_target))
		finish_action(controller, FALSE)
		return
	var/pocket_choice = prob(50) ? ITEM_SLOT_RPOCKET : ITEM_SLOT_LPOCKET
	if(prob(50) && living_target.can_put_in_hand(held_item))
		living_target.put_in_hand(held_item)
	else if(held_item.mob_can_equip(living_target, pawn, pocket_choice, TRUE))
		living_target.equip_to_slot(held_item, pocket_choice)

	finish_action(controller, TRUE)

/datum/ai_behavior/consume
	required_distance = 1
	behavior_flags = AI_BEHAVIOR_REQUIRE_MOVEMENT
	action_cooldown = 2 SECONDS

/datum/ai_behavior/consume/setup(datum/ai_controller/controller, obj/item/target)
	. = ..()
	controller.current_movement_target = target

/datum/ai_behavior/consume/perform(seconds_per_tick, datum/ai_controller/controller, obj/item/target)
	. = ..()
	var/mob/living/pawn = controller.pawn

	if(!(target in pawn.held_items))
		if(!pawn.put_in_hand_check(target))
			finish_action(controller, FALSE)
			return

		pawn.put_in_hands(target)

	target.melee_attack_chain(pawn, pawn)

	if(QDELETED(target) || prob(10)) // Even if we don't finish it all we can randomly decide to be done
		finish_action(controller, TRUE)

/**find and set
 * Finds an item near themselves, sets a blackboard key as it. Very useful for ais that need to use machines or something.
 * if you want to do something more complicated than find a single atom, change the search_tactic() proc
 * cool tip: search_tactic() can set lists
 */
/datum/ai_behavior/find_and_set
	action_cooldown = 5 SECONDS
	///search range in how many tiles around the pawn to look for the path
	var/search_range = 7
	//optional, don't use if you're changing search_tactic()
	var/locate_path
	var/bb_key_to_set

/datum/ai_behavior/find_and_set/perform(seconds_per_tick, datum/ai_controller/controller)
	. = ..()
	var/find_this_thing = search_tactic(controller)
	if(find_this_thing)
		controller.set_blackboard_key(bb_key_to_set, find_this_thing)
		finish_action(controller, TRUE)
	else
		finish_action(controller, FALSE)

/datum/ai_behavior/find_and_set/proc/search_tactic(datum/ai_controller/controller)
	return locate(locate_path) in oview(search_range, controller.pawn)


/// This behavior involves attacking a target.
/datum/ai_behavior/attack
	behavior_flags = AI_BEHAVIOR_REQUIRE_MOVEMENT | AI_BEHAVIOR_MOVE_AND_PERFORM
	required_distance = 1

/datum/ai_behavior/attack/perform(seconds_per_tick, datum/ai_controller/controller)
	. = ..()
	var/mob/living/living_pawn = controller.pawn
	if(!istype(living_pawn) || !isturf(living_pawn.loc))
		return

	var/atom/movable/attack_target = controller.blackboard[BB_ATTACK_TARGET]
	if(!attack_target || !can_see(living_pawn, attack_target, length=controller.blackboard[BB_VISION_RANGE]))
		finish_action(controller, FALSE)
		return

	var/mob/living/living_target = attack_target
	if(istype(living_target) && (living_target.stat == DEAD))
		finish_action(controller, TRUE)
		return

	controller.current_movement_target = living_target
	attack(controller, living_target)

/datum/ai_behavior/attack/finish_action(datum/ai_controller/controller, succeeded)
	. = ..()
	controller.clear_blackboard_key(BB_ATTACK_TARGET)

/// A proc representing when the mob is pushed to actually attack the target. Again, subtypes can be used to represent different attacks from different animals, or it can be some other generic behavior
/datum/ai_behavior/attack/proc/attack(datum/ai_controller/controller, mob/living/living_target)
	var/mob/living/living_pawn = controller.pawn
	if(!istype(living_pawn))
		return
	living_pawn.ClickOn(living_target, list())

/// This behavior involves attacking a target.
/datum/ai_behavior/follow
	behavior_flags = AI_BEHAVIOR_REQUIRE_MOVEMENT | AI_BEHAVIOR_MOVE_AND_PERFORM
	required_distance = 1

/datum/ai_behavior/follow/perform(seconds_per_tick, datum/ai_controller/controller)
	. = ..()
	var/mob/living/living_pawn = controller.pawn
	if(!istype(living_pawn) || !isturf(living_pawn.loc))
		return

	var/atom/movable/follow_target = controller.blackboard[BB_FOLLOW_TARGET]
	if(!follow_target || get_dist(living_pawn, follow_target) > controller.blackboard[BB_VISION_RANGE])
		finish_action(controller, FALSE)
		return

	var/mob/living/living_target = follow_target
	if(istype(living_target) && (living_target.stat == DEAD))
		finish_action(controller, TRUE)
		return

	controller.current_movement_target = living_target

/datum/ai_behavior/follow/finish_action(datum/ai_controller/controller, succeeded)
	. = ..()
	controller.clear_blackboard_key(BB_FOLLOW_TARGET)



/datum/ai_behavior/perform_emote

/datum/ai_behavior/perform_emote/perform(seconds_per_tick, datum/ai_controller/controller, emote)
	var/mob/living/living_pawn = controller.pawn
	if(!istype(living_pawn))
		return
	living_pawn.manual_emote(emote)
	finish_action(controller, TRUE)

/datum/ai_behavior/perform_speech

/datum/ai_behavior/perform_speech/perform(seconds_per_tick, datum/ai_controller/controller, speech)
	var/mob/living/living_pawn = controller.pawn
	if(!istype(living_pawn))
		return
	living_pawn.say(speech, forced = "AI Controller")
	finish_action(controller, TRUE)
