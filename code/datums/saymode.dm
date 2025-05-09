/datum/saymode
	var/key
	var/mode

//Return FALSE if you have handled the message. Otherwise, return TRUE and saycode will continue doing saycode things.
//user = whoever said the message
//message = the message
//language = the language.
/datum/saymode/proc/handle_message(mob/living/user, message, datum/language/language)
	return TRUE


/datum/saymode/changeling
	key = MODE_KEY_CHANGELING
	mode = MODE_CHANGELING

/datum/saymode/changeling/handle_message(mob/living/user, message, datum/language/language)
	switch(user.lingcheck())
		if(LINGHIVE_LINK)
			var/msg = span_changeling("<b>[user.mind]:</b> [message]")
			for(var/_M in GLOB.player_list)
				var/mob/M = _M
				if(M in GLOB.dead_mob_list)
					var/link = FOLLOW_LINK(M, user)
					to_chat(M, "[link] [msg]")
				else
					switch(M.lingcheck())
						if (LINGHIVE_LING)
							var/mob/living/L = M
							if (!HAS_TRAIT(L, CHANGELING_HIVEMIND_MUTE))
								to_chat(M, msg)
						if(LINGHIVE_LINK)
							to_chat(M, msg)
						if(LINGHIVE_OUTSIDER)
							if(prob(40))
								to_chat(M, span_changeling("We can faintly sense an outsider trying to communicate through the hivemind..."))
		if(LINGHIVE_LING)
			if (HAS_TRAIT(user, CHANGELING_HIVEMIND_MUTE))
				to_chat(user, span_warning("The poison in the air hinders our ability to interact with the hivemind."))
				return FALSE
			var/datum/antagonist/changeling/changeling = user.mind.has_antag_datum(/datum/antagonist/changeling)
			var/msg = span_changeling("<b>[changeling.changelingID]:</b> [message]")
			user.log_talk(message, LOG_SAY, tag="changeling [changeling.changelingID]")
			for(var/_M in GLOB.player_list)
				var/mob/M = _M
				if(M in GLOB.dead_mob_list)
					var/link = FOLLOW_LINK(M, user)
					to_chat(M, "[link] [msg]")
				else
					switch(M.lingcheck())
						if(LINGHIVE_LINK)
							to_chat(M, msg)
						if(LINGHIVE_LING)
							var/mob/living/L = M
							if (!HAS_TRAIT(L, CHANGELING_HIVEMIND_MUTE))
								to_chat(M, msg)
						if(LINGHIVE_OUTSIDER)
							if(prob(40))
								to_chat(M, span_changeling("We can faintly sense another of our kind trying to communicate through the hivemind..."))
		if(LINGHIVE_OUTSIDER)
			to_chat(user, span_changeling("Our senses have not evolved enough to be able to communicate this way..."))
	return FALSE


/datum/saymode/xeno
	key = "a"
	mode = MODE_ALIEN

/datum/saymode/xeno/handle_message(mob/living/user, message, datum/language/language)
	if(user.hivecheck())
		user.alien_talk(message)
	return FALSE
//WS begin - Borers
/datum/saymode/borer
	key = MODE_KEY_BORER
	mode = MODE_BORER

/datum/saymode/borer/handle_message(mob/living/user, message, datum/language/language)
	if(user.borercheck())
		user.borer_talk(message)
	return FALSE
//WS end

/datum/saymode/vocalcords
	key = MODE_KEY_VOCALCORDS
	mode = MODE_VOCALCORDS

/datum/saymode/vocalcords/handle_message(mob/living/user, message, datum/language/language)
	if(iscarbon(user))
		var/mob/living/carbon/C = user
		var/obj/item/organ/vocal_cords/V = C.getorganslot(ORGAN_SLOT_VOICE)
		if(V && V.can_speak_with())
			V.handle_speech(message) //message
			V.speak_with(message) //action
	return FALSE


/datum/saymode/binary //everything that uses .b (silicons, drones)
	key = MODE_KEY_BINARY
	mode = MODE_BINARY

/datum/saymode/binary/handle_message(mob/living/user, message, datum/language/language)
	if(isdrone(user))
		var/mob/living/simple_animal/drone/D = user
		D.drone_chat(message)
		return FALSE
	if(user.binarycheck())
		user.robot_talk(message)
		return FALSE
	return FALSE


/datum/saymode/holopad
	key = "h"
	mode = MODE_HOLOPAD

/datum/saymode/holopad/handle_message(mob/living/user, message, datum/language/language)
	if(isAI(user))
		var/mob/living/silicon/ai/AI = user
		AI.holopad_talk(message, language)
		return FALSE
	return TRUE
