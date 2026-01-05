/**
 * Attaches to an item, if that item is dropped on the floor delete it
 */
/datum/element/vanish_on_drop
	element_flags = ELEMENT_BESPOKE

/datum/element/vanish_on_drop/Attach(datum/target)
	. = ..()
	if(!isitem(target))
		return COMPONENT_INCOMPATIBLE
	#warn COMSIG_CASING_EJECTED only exists in TG but should add it here if your going to add this.
	// RegisterSignals(target, list(COMSIG_ITEM_DROPPED, COMSIG_CASING_EJECTED), PROC_REF(vanish_on_drop))
	RegisterSignals(target, list(COMSIG_ITEM_DROPPED), PROC_REF(vanish_on_drop))

/datum/element/vanish_on_drop/Detach(datum/source)
	. = ..()
	#warn see above.
	// UnregisterSignal(source, list(COMSIG_ITEM_DROPPED, COMSIG_CASING_EJECTED))
	UnregisterSignal(source, list(COMSIG_ITEM_DROPPED))

/datum/element/vanish_on_drop/proc/vanish_on_drop(atom/source)
	SIGNAL_HANDLER
	if(isturf(source.loc))
		animate(source, alpha = 0, 5 SECONDS)
		addtimer(CALLBACK(src, PROC_REF(try_delete), source), 5 SECONDS)

/datum/element/vanish_on_drop/proc/try_delete(atom/source)
	if(QDELETED(source))
		return
	if(isturf(source.loc))
		qdel(source)
	else
		// Could be either `alpha = 255` or `alpha = source::alpha`
		// Im not sold if it should just set back to full or try to reset to the atoms default state.
		animate(source, alpha = 255, 1 SECONDS)
