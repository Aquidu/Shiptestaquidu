///outfits for ctf
/datum/outfit/ctf ///literally just so this file is shorter
	name = "CTF Base Outfit"
	ears = /obj/item/radio/headset/alt
	gloves = /obj/item/clothing/gloves/color/black
	shoes = /obj/item/clothing/shoes/combat
	l_pocket = /obj/item/tank/internals/emergency_oxygen/double
	internals_slot = ITEM_SLOT_LPOCKET
	implants = list(/obj/item/organ/cyberimp/mouth/breathing_tube) ///this is so you don't drop your gun when a smoke grenade goes off, while still exposing your face
	r_pocket = /obj/item/melee/knife/combat
	id = /obj/item/card/id

//CLIP
/datum/outfit/ctf/clip
	name = "CTF Base Outfit (Minutemen)"
	head = /obj/item/clothing/head/helmet/bulletproof/x11/clip
	suit = /obj/item/clothing/suit/armor/vest/bulletproof
	uniform = /obj/item/clothing/under/clip/minutemen

/datum/outfit/ctf/clip/rifleman
	name = "CTF Rifleman (Minutemen)"
	suit_store = /obj/item/gun/ballistic/automatic/assault/cm82
	belt = /obj/item/storage/belt/military/clip/cm82

/datum/outfit/ctf/clip/engineer
	name = "CTF Engineer (Minutemen)"
	suit_store = /obj/item/gun/ballistic/automatic/smg/cm5
	belt = /obj/item/storage/belt/military/clip/cm5/ctf
	eyes = /obj/item/clothing/glasses/welding
	accessory = /obj/item/clothing/accessory/armband/engine
	back = /obj/item/storage/backpack/satchel/eng
		backpack_contents = list(
			/obj/item/grenade/c4 = 2,
			/obj/item/crowbar/red,
			/obj/item/weldingtool/electric,
			/obj/item/extinguisher,
			/obj/item/stack/rods/twentyfive,
			/obj/item/stack/wood/twentyfive)

/datum/outfit/ctf/clip/marksman
	name = "CTF Marksman (Minutemen)"
	suit_store = /obj/item/gun/ballistic/automatic/marksman/f4
	belt = /obj/item/storage/belt/military/clip/f4/ctf
	neck = /obj/item/binoculars
	suit = NULL
	head = /obj/item/clothing/head/clip

/datum/outfit/ctf/clip/medic
	name = "CTF Medic (Minutemen)"
	suit_store = /obj/item/gun/ballistic/automatic/smg/cm5
	belt = /obj/item/storage/belt/military/clip/cm5/ctf


//FRONTIERSMEN
/datum/outfit/ctf/frontiersmen
	name = "CTF Base Outfit (Frontiersmen)"
	suit = /obj/item/clothing/suit/armor/vest/bulletproof/frontier
	suit_store = /obj/item/gun/ballistic/automatic/assault/skm
	l_pocket = /obj/item/ammo_box/magazine/m9mm_mauler
	belt = /obj/item/storage/belt/security/military/frontiersmen/skm_ammo



/datum/outfit/ctf/post_equip(mob/living/carbon/human/H, visualsOnly=FALSE)
	if(visualsOnly)
		return
	var/list/no_drops = list()
	var/obj/item/card/id/W = H.wear_id
	no_drops += W
	W.registered_name = H.real_name
	W.update_label()

	no_drops += H.get_item_by_slot(ITEM_SLOT_OCLOTHING)
	no_drops += H.get_item_by_slot(ITEM_SLOT_GLOVES)
	no_drops += H.get_item_by_slot(ITEM_SLOT_FEET)
	no_drops += H.get_item_by_slot(ITEM_SLOT_ICLOTHING)
	no_drops += H.get_item_by_slot(ITEM_SLOT_EARS)
	for(var/i in no_drops)
		var/obj/item/I = i
		ADD_TRAIT(I, TRAIT_NODROP, CAPTURE_THE_FLAG_TRAIT)
