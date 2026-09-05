/turf/open/floor/plating/asteroid/waterplanet
	name = "wet rocky ground"
	desc = "The ground has water flowing through it."

	icon = 'icons/turf/floors/wateryrock.dmi'
	icon_state = "rock-255"
	base_icon_state = "rock"
	gender = PLURAL

	baseturfs = /turf/open/floor/plating/asteroid/waterplanet
	initial_gas_mix = "o2=22;n2=82;TEMP=255.37"
	planetary_atmos = TRUE
	attachment_holes = FALSE
	footstep = FOOTSTEP_FLOOR
	barefootstep = FOOTSTEP_HARD_BAREFOOT
	clawfootstep = FOOTSTEP_HARD_CLAW
	heavyfootstep = FOOTSTEP_GENERIC_HEAVY

	layer = SAND_TURF_LAYER
	smooth_icon = 'icons/turf/floors/wateryrock.dmi'
	smoothing_flags = SMOOTH_BITMASK
	smoothing_groups = list(SMOOTH_GROUP_TURF_OPEN, SMOOTH_GROUP_FLOOR_ASH_ROCKY)
	canSmoothWith = list(SMOOTH_GROUP_CLOSED_TURFS, SMOOTH_GROUP_FLOOR_ASH_ROCKY)
	gender = PLURAL

	floor_variance = 0


/turf/open/water/stormy_planet_lit
	name = "thalassic water"
	desc = "Deep, murky blue stretches out into the infinity beneath you."
	icon_state = "deepwater_aqua"
	light_color = "#09121a"
	light_range = 2
	light_power = 1
	immerse_overlay = "immerse_deep"
	immerse_overlay_alpha = 210
	is_swimming_tile = TRUE
	initial_gas_mix = "o2=22;n2=82;TEMP=255.37"
	baseturfs = /turf/open/water/stormy_planet_lit

/turf/open/water/stormy_planet_underground
	icon_state = "shallowwater_aqua"
	light_range = 0
	initial_gas_mix = "o2=22;n2=82;TEMP=255.37"
	baseturfs = /turf/open/water/stormy_planet_underground
