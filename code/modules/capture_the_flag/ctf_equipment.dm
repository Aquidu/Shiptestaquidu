///CLIP///

/obj/item/storage/belt/military/clip/cm82/ctf/ComponentInitialize()
	. = ..()
	var/datum/component/storage/STR = GetComponent(/datum/component/storage)
	STR.max_items = 6
/obj/item/storage/belt/military/clip/cm82/ctf/PopulateContents()
	for(var/i in 1 to 3)
		new /obj/item/ammo_box/magazine/p16(src)
	new /obj/item/grenade/frag(src)
	new /obj/item/gun/ballistic/automatic/pistol/cm23(src)
	new /obj/item/ammo_box/magazine/cm23(src)

/obj/item/storage/belt/military/clip/cm5/ctf/ComponentInitialize()
	. = ..()
	var/datum/component/storage/STR = GetComponent(/datum/component/storage)
	STR.max_items = 6
/obj/item/storage/belt/military/clip/cm5/ctf/PopulateContents()
	for(var/i in 1 to 3)
		new /obj/item/ammo_box/magazine/cm5_9mm(src)
	new /obj/item/grenade/barrier(src)
	new /obj/item/gun/ballistic/automatic/pistol/cm23(src)
	new /obj/item/ammo_box/magazine/cm23(src)

/obj/item/storage/belt/military/clip/f4/ctf/ComponentInitialize()
	. = ..()
	var/datum/component/storage/STR = GetComponent(/datum/component/storage)
	STR.max_items = 6
/obj/item/storage/belt/military/clip/f4/ctf/PopulateContents()
	for(var/i in 1 to 3)
		new /obj/item/ammo_box/magazine/f4_308(src)
	new /obj/item/grenade/smokebomb(src)
	new /obj/item/gun/ballistic/automatic/pistol/cm357(src)
	new /obj/item/ammo_box/magazine/cm357(src)

/obj/item/storage/belt/medical/webbing/clip/ctf/ComponentInitialize()
	. = ..()
	var/datum/component/storage/STR = GetComponent(/datum/component/storage)
	STR.max_items = 6
	STR.set_holdable(list(
	/obj/item/healthanalyzer,
	/obj/item/stack/medical,
	/obj/item/reagent_containers/hypospray,
	/obj/item/hypospray,
	/obj/item/ammo_box/magazine
	))
/obj/item/storage/belt/medical/webbing/clip/ctf/PopulateContents()
	for(var/i in 1 to 3)
		new /obj/item/ammo_box/magazine/cm5_9mm(src)
	new /obj/item/grenade/smokebomb(src)
	new /obj/item/hypospray/mkii/mkiii/combat/ctf(src)
	new /obj/item/healthanalyzer(src) ///i mean if you got time to use it

/obj/item/storage/belt/military/clip/cm15/ctf/ComponentInitialize()
	. = ..()
	var/datum/component/storage/STR = GetComponent(/datum/component/storage)
	STR.max_items = 6
/obj/item/storage/belt/military/clip/cm15/ctf/PopulateContents()
	for(var/i in 1 to 3)
		new /obj/item/ammo_box/magazine/cm15_12g(src)
	new /obj/item/grenade/flashbang(src)
	new /obj/item/gun/ballistic/automatic/pistol/cm70(src)
	new /obj/item/ammo_box/magazine/m9mm_cm70(src)

/obj/item/storage/belt/military/clip/alt/ecm6/ctf/ComponentInitialize()
	. = ..()
	var/datum/component/storage/STR = GetComponent(/datum/component/storage)
	STR.max_items = 6
/obj/item/storage/belt/military/clip/alt/ecm6/ctf/PopulateContents()
	for(var/i in 1 to 3)
		new /obj/item/stock_parts/cell/gun/kalix(src)
	new /obj/item/grenade/chem_grenade/incendiary(src)
	new /obj/item/gun/ballistic/automatic/pistol/cm23(src)
	new /obj/item/ammo_box/magazine/cm23(src)


///FRONTIES///

/obj/item/storage/belt/security/military/frontiersmen/skm_ammo/ctf/ComponentInitialize()
	. = ..()
	var/datum/component/storage/STR = GetComponent(/datum/component/storage)
	STR.max_items = 6
/obj/item/storage/belt/security/military/frontiersmen/skm_ammo/ctf/PopulateContents()
	for(var/i in 1 to 3)
		new /obj/item/ammo_box/magazine/skm_762_40(src)
	new /obj/item/grenade/frag(src)
	new /obj/item/gun/ballistic/automatic/pistol/mauler/regular(src)
	new /obj/item/ammo_box/magazine/m9mm_mauler(src)

/obj/item/storage/belt/security/military/frontiersmen/spitter_ammo/ctf/PopulateContents()
	for(var/i in 1 to 3)
		new /obj/item/ammo_box/magazine/spitter_9mm(src)
	new /obj/item/grenade/barrier(src)
	new /obj/item/gun/ballistic/automatic/pistol/mauler/regular(src)
	new /obj/item/ammo_box/magazine/m9mm_mauler(src)

/obj/item/storage/belt/security/military/frontiersmen/f3_ammo/ctf/PopulateContents()
	for(var/i in 1 to 3)
		new /obj/item/ammo_box/magazine/f4_308(src)
	new /obj/item/grenade/smokebomb(src)
	new /obj/item/gun/ballistic/automatic/pistol/mauler/regular(src)
	new /obj/item/ammo_box/magazine/m9mm_mauler(src)

/obj/item/storage/belt/medical/webbing/frontiersmen/ctf/ComponentInitialize()
	. = ..()
	var/datum/component/storage/STR = GetComponent(/datum/component/storage)
	STR.max_items = 6
	STR.set_holdable(list(
	/obj/item/healthanalyzer,
	/obj/item/stack/medical,
	/obj/item/reagent_containers/hypospray,
	/obj/item/hypospray,
	/obj/item/ammo_box/magazine
	))

/obj/item/storage/belt/medical/webbing/frontiersmen/ctf/PopulateContents()
	for(var/i in 1 to 3)
		new /obj/item/ammo_box/magazine/spitter_9mm(src)
	new /obj/item/grenade/smokebomb(src)
	new /obj/item/hypospray/mkii/mkiii/combat/ctf(src)
	new /obj/item/healthanalyzer(src) ///i mean if you got time to use it

/obj/item/storage/belt/security/military/frontiersmen/slammer_ammo/ctf/PopulateContents()
	for(var/i in 1 to 3)
		new /obj/item/ammo_box/magazine/m12g_slammer(src)
	new /obj/item/grenade/flashbang(src)
	new /obj/item/gun/ballistic/automatic/pistol/mauler/regular(src)
	new /obj/item/ammo_box/magazine/m9mm_mauler(src)

/obj/item/storage/belt/security/military/frontiersmen/wasp_ammo/ctf/PopulateContents()
	for(var/i in 1 to 3)
		new /obj/item/stock_parts/cell/gun(src)
	new /obj/item/grenade/chem_grenade/incendiary(src)
	new /obj/item/gun/ballistic/automatic/pistol/mauler/regular(src)
	new /obj/item/ammo_box/magazine/m9mm_mauler(src)



/obj/item/reagent_containers/glass/bottle/vial/large/preloaded/combat/ctf
	comes_with = list(
		/datum/reagent/medicine/chitosan = 15,
		/datum/reagent/medicine/salglu_solution = 15,
		/datum/reagent/medicine/hadrakine = 30,
		/datum/reagent/medicine/quardexane = 30,
		/datum/reagent/medicine/atropine = 15,
		/datum/reagent/medicine/carfencadrizine = 15, ///can save people from crit, but not for tanking
	)

