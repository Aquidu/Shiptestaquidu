// This is a list of turf types we dont want to assign to baseturfs unless through initialization or explicitly
GLOBAL_LIST_INIT(blacklisted_automated_baseturfs, typecacheof(list(
	/turf/open/space,
	/turf/baseturf_bottom,
	)))

/turf/proc/empty(turf_type=/turf/open/space, baseturf_type, list/ignore_typecache, flags)
	// Remove all atoms except observers, landmarks, docking ports
	var/static/list/ignored_atoms = typecacheof(list(/mob/dead, /obj/effect/landmark, /obj/docking_port, /atom/movable/lighting_object))
	var/list/allowed_contents = typecache_filter_list_reverse(GetAllContentsIgnoring(ignore_typecache), ignored_atoms)
	allowed_contents -= src
	for(var/i in 1 to allowed_contents.len)
		var/thing = allowed_contents[i]
		qdel(thing, force=TRUE)

	if(turf_type)
		ChangeTurf(turf_type, baseturf_type, flags)

/turf/proc/copyTurf(turf/T, copy_air, flags)
	if(T.type != type)
		var/obj/O
		if(underlays.len)	//we have underlays, which implies some sort of transparency, so we want to a snapshot of the previous turf as an underlay
			O = new()
			O.underlays.Add(T)
		T.ChangeTurf(type, null, flags)
		if(underlays.len)
			T.underlays = O.underlays
	if(T.icon_state != icon_state)
		T.icon_state = icon_state
	if(T.icon != icon)
		T.icon = icon
	if(atom_colours)
		T.atom_colours = atom_colours.Copy()
		T.update_atom_colour()
	if(T.dir != dir)
		T.setDir(dir)
	if(T.smoothing_flags != smoothing_flags)
		T.smoothing_flags = smoothing_flags
	return T

/turf/open/copyTurf(turf/T, copy_air = FALSE)
	. = ..()
	if(isopenturf(T))
		if(copy_air)
			var/turf/open/openTurf = T
			openTurf.air.copy_from(air)

//wrapper for ChangeTurf()s that you want to prevent/affect without overriding ChangeTurf() itself
/turf/proc/TerraformTurf(path, new_baseturf, flags)
	return ChangeTurf(path, new_baseturf, flags)

/turf/proc/get_z_base_turf()
	. = virtual_level_trait(ZTRAIT_BASETURF) || /turf/open/space
	if (!ispath(.))
		. = text2path(.)
		if (!ispath(.))
			warning("Z-level [z] has invalid baseturf '[virtual_level_trait(ZTRAIT_BASETURF)]'")
			. = /turf/open/space

// Creates a new turf
// new_baseturfs can be either a single type or list of types, formated the same as baseturfs. see turf.dm
/turf/proc/ChangeTurf(path, list/new_baseturfs, flags)
	switch(path)
		if(null)
			return
		if(/turf/baseturf_bottom)
			path = get_z_base_turf()
		if(/turf/open/space/basic)
			// basic doesn't initialize and this will cause issues
			// no warning though because this can happen naturaly as a result of it being built on top of
			path = /turf/open/space

	if(!GLOB.use_preloader && path == type && !(flags & CHANGETURF_FORCEOP) && (baseturfs == new_baseturfs)) // Don't no-op if the map loader requires it to be reconstructed, or if this is a new set of baseturfs
		return src
	if(flags & CHANGETURF_SKIP)
		return new path(src, virtual_z)

	var/old_dynamic_lighting = dynamic_lighting
	var/old_lighting_object = lighting_object
	var/old_lighting_corner_NE = lighting_corner_NE
	var/old_lighting_corner_SE = lighting_corner_SE
	var/old_lighting_corner_SW = lighting_corner_SW
	var/old_lighting_corner_NW = lighting_corner_NW
	var/old_directional_opacity = directional_opacity
	var/old_dynamic_lumcount = dynamic_lumcount
	var/old_opacity = opacity

	var/old_exl = explosion_level
	var/old_exi = explosion_id
	var/old_bp = blueprint_data
	blueprint_data = null

	var/list/old_baseturfs = baseturfs

	var/old_virtual_z = virtual_z
	var/list/post_change_callbacks = list()
	SEND_SIGNAL(src, COMSIG_TURF_CHANGE, path, new_baseturfs, flags, post_change_callbacks)

	changing_turf = TRUE
	qdel(src) //Just get the side effects and call Destroy
	//We do this here so anything that doesn't want to persist can clear itself
	var/list/old_comp_lookup = comp_lookup?.Copy()
	var/list/old_signal_procs = signal_procs?.Copy()
	var/turf/W = new path(src, virtual_z)

	// WARNING WARNING
	// Turfs DO NOT lose their signals when they get replaced, REMEMBER THIS
	// It's possible because turfs are fucked, and if you have one in a list and it's replaced with another one, the list ref points to the new turf
	if(old_comp_lookup)
		LAZYOR(W.comp_lookup, old_comp_lookup)
	if(old_signal_procs)
		LAZYOR(W.signal_procs, old_signal_procs)

	for(var/datum/callback/callback as anything in post_change_callbacks)
		callback.InvokeAsync(W)

	if(new_baseturfs)
		W.baseturfs = baseturfs_string_list(new_baseturfs, W)
	else
		W.baseturfs = baseturfs_string_list(old_baseturfs, W) //Just to be safe

	W.explosion_id = old_exi
	W.explosion_level = old_exl

	if(!(flags & CHANGETURF_DEFER_CHANGE))
		W.AfterChange(flags)

	W.blueprint_data = old_bp

	W.virtual_z = old_virtual_z

	lighting_corner_NE = old_lighting_corner_NE
	lighting_corner_SE = old_lighting_corner_SE
	lighting_corner_SW = old_lighting_corner_SW
	lighting_corner_NW = old_lighting_corner_NW

	dynamic_lumcount = old_dynamic_lumcount

	if(SSlighting.initialized)
		lighting_object = old_lighting_object

		directional_opacity = old_directional_opacity
		recalculate_directional_opacity()

		if (dynamic_lighting != old_dynamic_lighting)
			if (IS_DYNAMIC_LIGHTING(W))
				lighting_build_overlay()
			else
				lighting_clear_overlay()

		// Starlight recalculation is deferred if CHANGETURF_DEFER_BATCH is set.
		if(!(flags & CHANGETURF_DEFER_BATCH))
			for(var/turf/open/space/S in RANGE_TURFS(1, W)) //RANGE_TURFS is in code\__HELPERS\game.dm
				S.check_starlight(W)

	if(old_opacity != opacity && SSticker)
		GLOB.cameranet.bareMajorChunkChange(src)

	// Smoothing is deferred if CHANGETURF_DEFER_BATCH is set, or we're uninitialized
	if(!(flags & CHANGETURF_DEFER_BATCH) && (flags_1 & INITIALIZED_1))
		QUEUE_SMOOTH_NEIGHBORS(W)
		QUEUE_SMOOTH(W)

	return W

/turf/open/ChangeTurf(path, list/new_baseturfs, flags) //Resist the temptation to make this default to keeping air.
	//don't
	if(!SSair.initialized)
		return ..()
	if ((flags & CHANGETURF_INHERIT_AIR) && ispath(path, /turf/open) && air)
		var/datum/gas_mixture/stashed_air = new()
		stashed_air.copy_from(air)
		. = ..()
		if (!.) // changeturf failed or didn't do anything
			QDEL_NULL(stashed_air)
			return
		var/turf/open/newTurf = .
		if(turf_fire)
			if(isgroundlessturf(newTurf))
				QDEL_NULL(turf_fire)
			else
				newTurf.turf_fire = turf_fire
		newTurf.air.copy_from(stashed_air)
		update_air_ref(planetary_atmos ? AIR_REF_PLANETARY_TURF : AIR_REF_OPEN_TURF)
		QDEL_NULL(stashed_air)
	else
		if(turf_fire)
			QDEL_NULL(turf_fire)
		if(ispath(path, /turf/open))
			. = ..()
			if(!istype(air, /datum/gas_mixture))
				Initalize_Atmos(0)
		else
			update_air_ref(AIR_REF_CLOSED_TURF)
			. = ..()


// Take off the top layer turf and replace it with the next baseturf down
/turf/proc/ScrapeAway(amount=1, flags)
	if(!amount)
		return
	if(length(baseturfs))
		var/list/new_baseturfs = baseturfs.Copy()
		var/turf_type = new_baseturfs[max(1, new_baseturfs.len - amount + 1)]
		while(ispath(turf_type, /turf/baseturf_skipover))
			amount++
			if(amount > new_baseturfs.len)
				CRASH("The bottomost baseturf of a turf is a skipover [src]([type])")
			turf_type = new_baseturfs[max(1, new_baseturfs.len - amount + 1)]
		new_baseturfs.len -= min(amount, new_baseturfs.len - 1) // No removing the very bottom
		if(new_baseturfs.len == 1)
			new_baseturfs = new_baseturfs[1]
		return ChangeTurf(turf_type, new_baseturfs, flags)

	if(baseturfs == type)
		return src

	return ChangeTurf(baseturfs, baseturfs, flags) // The bottom baseturf will never go away

// Take the input as baseturfs and put it underneath the current baseturfs
// If fake_turf_type is provided and new_baseturfs is not the baseturfs list will be created identical to the turf type's
// If both or just new_baseturfs is provided they will be inserted below the existing baseturfs
/turf/proc/PlaceOnBottom(list/new_baseturfs, turf/fake_turf_type)
	if(fake_turf_type)
		if(!new_baseturfs)
			if(!length(baseturfs))
				baseturfs = list(baseturfs)
			var/list/old_baseturfs = baseturfs.Copy()
			assemble_baseturfs(fake_turf_type)
			if(!length(baseturfs))
				baseturfs = list(baseturfs)
			baseturfs = baseturfs_string_list((baseturfs - (baseturfs & GLOB.blacklisted_automated_baseturfs)) + old_baseturfs, src)
			return
		else if(!length(new_baseturfs))
			new_baseturfs = list(new_baseturfs, fake_turf_type)
		else
			new_baseturfs += fake_turf_type
	if(!length(baseturfs))
		baseturfs = list(baseturfs)
	baseturfs = baseturfs_string_list(new_baseturfs + baseturfs, src)

// Make a new turf and put it on top
// The args behave identical to PlaceOnBottom except they go on top
// Things placed on top of closed turfs will ignore the topmost closed turf
// Returns the new turf
/turf/proc/PlaceOnTop(list/new_baseturfs, turf/fake_turf_type, flags)
	var/area/turf_area = loc
	if(new_baseturfs && !length(new_baseturfs))
		new_baseturfs = list(new_baseturfs)
	flags = turf_area.PlaceOnTopReact(src, new_baseturfs, fake_turf_type, flags) // A hook so areas can modify the incoming args

	var/turf/newT
	if(flags & CHANGETURF_SKIP) // We haven't been initialized
		if(flags_1 & INITIALIZED_1)
			stack_trace("CHANGETURF_SKIP was used in a PlaceOnTop call for a turf that's initialized. This is a mistake. [src]([type])")
		assemble_baseturfs()

	if(!length(baseturfs))
		baseturfs = list(baseturfs)

	if(fake_turf_type)
		if(!new_baseturfs) // If no baseturfs list then we want to create one from the turf type
			var/list/old_baseturfs = baseturfs.Copy()
			if(!istype(src, /turf/closed))
				old_baseturfs += type
			newT = ChangeTurf(fake_turf_type, null, flags)
			newT.assemble_baseturfs(initial(fake_turf_type.baseturfs)) // The baseturfs list is created like roundstart
			if(!length(newT.baseturfs))
				newT.baseturfs = list(baseturfs)
			// The old baseturfs are put underneath, and we sort out the unwanted ones
			newT.baseturfs = baseturfs_string_list(old_baseturfs + (newT.baseturfs - GLOB.blacklisted_automated_baseturfs), newT)
			return newT
		else
			if(!istype(src, /turf/closed))
				new_baseturfs = list(type) + new_baseturfs
			baseturfs = baseturfs_string_list(baseturfs + new_baseturfs, src)
			return ChangeTurf(fake_turf_type, null, flags)
	else
		if(!istype(src, /turf/closed))
			baseturfs = baseturfs_string_list(baseturfs + type, src)
		var/turf/change_type
		if(length(new_baseturfs))
			change_type = new_baseturfs[new_baseturfs.len]
			new_baseturfs.len--
			if(new_baseturfs.len)
				baseturfs = baseturfs_string_list(baseturfs + new_baseturfs, src)
		else
			change_type = new_baseturfs
		return ChangeTurf(change_type, null, flags)

// Copy an existing turf and put it on top
// Returns the new turf
/turf/proc/CopyOnTop(turf/copytarget, ignore_bottom=1, depth=INFINITY, copy_air = FALSE, flags)
	var/list/new_baseturfs = list()
	new_baseturfs += baseturfs
	new_baseturfs += type

	if(depth)
		var/list/target_baseturfs
		if(length(copytarget.baseturfs))
			// with default inputs this would be Copy(clamp(2, -INFINITY, baseturfs.len))
			// Don't forget a lower index is lower in the baseturfs stack, the bottom is baseturfs[1]
			target_baseturfs = copytarget.baseturfs.Copy(clamp(1 + ignore_bottom, 1 + copytarget.baseturfs.len - depth, copytarget.baseturfs.len))
		else if(!ignore_bottom)
			target_baseturfs = list(copytarget.baseturfs)
		if(target_baseturfs)
			target_baseturfs -= new_baseturfs & GLOB.blacklisted_automated_baseturfs
			new_baseturfs += target_baseturfs

	var/turf/newT = copytarget.copyTurf(src, copy_air, flags)
	newT.baseturfs = baseturfs_string_list(new_baseturfs, newT)
	return newT


//If you modify this function, ensure it works correctly with lateloaded map templates.
/turf/proc/AfterChange(flags) //called after a turf has been replaced in ChangeTurf()
	levelupdate()

	ImmediateCalculateAdjacentTurfs()

	//update firedoor adjacency
	var/list/turfs_to_check = get_adjacent_open_turfs(src) | src
	for(var/I in turfs_to_check)
		var/turf/T = I
		for(var/obj/machinery/door/firedoor/FD in T)
			FD.CalculateAffectingAreas()


/turf/open/AfterChange(flags)
	..()
	RemoveLattice()
	if(!(flags & (CHANGETURF_IGNORE_AIR | CHANGETURF_INHERIT_AIR)))
		Assimilate_Air()

//////Assimilate Air//////
/turf/open/proc/Assimilate_Air()
	var/turf_count = LAZYLEN(atmos_adjacent_turfs)
	if(blocks_air || !turf_count) //if there weren't any open turfs, no need to update.
		return

	var/datum/gas_mixture/total = new//Holders to assimilate air from nearby turfs

	for(var/T in atmos_adjacent_turfs)
		var/turf/open/S = T
		if(!S.air)
			continue
		total.merge(S.air)

	air.copy_from(total.remove_ratio(1/turf_count))

/turf/proc/ReplaceWithLattice()
	ScrapeAway(flags = CHANGETURF_INHERIT_AIR)
	new /obj/structure/lattice(locate(x, y, z))
