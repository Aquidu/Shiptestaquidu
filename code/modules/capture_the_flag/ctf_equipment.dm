///CLIP///

///BELTS///
/obj/item/storage/belt/military/clip/cm82/ctf
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

/obj/item/storage/belt/military/clip/cm5/ctf
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

/obj/item/storage/belt/military/clip/f4/ctf
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


