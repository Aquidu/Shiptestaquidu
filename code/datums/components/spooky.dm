/datum/component/spooky
	var/too_spooky = TRUE //will it spawn a new instrument?

/datum/component/spooky/Initialize()
	RegisterSignal(parent, COMSIG_ITEM_ATTACK, PROC_REF(spectral_attack))

/datum/component/spooky/proc/spectral_attack(datum/source, mob/living/carbon/C, mob/user)
	SIGNAL_HANDLER

	INVOKE_ASYNC(src, PROC_REF(spectral_attack_async), source, C, user)

/datum/component/spooky/proc/spectral_attack_async(datum/source, mob/living/carbon/C, mob/user)

	if(ishuman(user)) //this weapon wasn't meant for mortals.
		var/mob/living/carbon/human/U = user
		if(!istype(U.dna.species, /datum/species/skeleton))
			U.adjustStaminaLoss(35) //Extra Damage
			U.set_timed_status_effect(70 SECONDS, /datum/status_effect/jitter, only_if_higher = TRUE)
			U.stuttering = 20
			if(U.getStaminaLoss() > 95)
				to_chat(U, "<font color ='red', size ='4'><B>Your ears weren't meant for this spectral sound.</B></font>")
				spectral_change(U)
			return

	if(ishuman(C))
		var/mob/living/carbon/human/H = C
		if(istype(H.dna.species, /datum/species/skeleton))
			return //undeads are unaffected by the spook-pocalypse.
		if(istype(H.dna.species, /datum/species/zombie))
			H.adjustStaminaLoss(25)
			H.Paralyze(15) //zombies can't resist the doot
		C.set_timed_status_effect(70 SECONDS, /datum/status_effect/jitter, only_if_higher = TRUE)
		C.stuttering = 20
		if((!istype(H.dna.species, /datum/species/skeleton)) && (!istype(H.dna.species, /datum/species/android)) && (!istype(H.dna.species, /datum/species/jelly)))
			C.adjustStaminaLoss(25) //boneless humanoids don't lose the will to live
		to_chat(C, "<font color='red' size='4'><B>DOOT</B></font>")
		spectral_change(H)

	else //the sound will spook monkeys.
		C.set_timed_status_effect(15 SECONDS, /datum/status_effect/jitter, only_if_higher = TRUE)
		C.stuttering = 20

/datum/component/spooky/proc/spectral_change(mob/living/carbon/human/H, mob/user)
	if((H.getStaminaLoss() > 95) && (!istype(H.dna.species, /datum/species/skeleton)) && (!istype(H.dna.species, /datum/species/android)) && (!istype(H.dna.species, /datum/species/jelly)))
		H.Paralyze(20)
		H.set_species(/datum/species/skeleton)
		H.visible_message(span_warning("[H] has given up on life as a mortal."))
		var/T = get_turf(H)
		if(too_spooky)
			if(prob(30))
				new/obj/item/instrument/saxophone/spectral(T)
			else if(prob(30))
				new/obj/item/instrument/trumpet/spectral(T)
			else if(prob(30))
				new/obj/item/instrument/trombone/spectral(T)
			else
				to_chat(H, span_boldwarning("The spooky gods forgot to ship your instrument. Better luck next unlife."))
		to_chat(H, span_boldnotice("You are the spooky skeleton!"))
		to_chat(H, span_boldnotice("A new life and identity has begun. Help your fellow skeletons into bringing out the spooky-pocalypse. You haven't forgotten your past life, and are still beholden to past loyalties."))
		change_name(H)	//time for a new name!

/datum/component/spooky/proc/change_name(mob/living/carbon/human/H)
	var/t = sanitize_name(stripped_input(H, "Enter your new skeleton name", H.real_name, null, MAX_NAME_LEN))
	if(!t)
		t = "spooky skeleton"
	H.fully_replace_character_name(null, t)
