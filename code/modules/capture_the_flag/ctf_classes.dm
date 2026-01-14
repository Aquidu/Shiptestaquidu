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

	///Description to be shown in the class selection menu
	var/class_description = "If you're reading this, something has gone wrong."
	///Radio frequency to assign players with this outfit
	var/team_radio_freq = FREQ_COMMON // they won't be able to use this on the centcom z-level, so ffa players cannot use radio
	///Icon file for the class radial menu icons
	var/icon = 'icons/hud/radial_ctf.dmi'
	///Icon state for this class
	var/icon_state = "john_ctf"
	///Do they get a headset?
	var/has_radio = TRUE
	///Do they get an ID?
	var/has_card = TRUE
	///Which slots to apply TRAIT_NODROP to the items in
	var/list/nodrop_slots = list(ITEM_SLOT_OCLOTHING, ITEM_SLOT_GLOVES, ITEM_SLOT_FEET, ITEM_SLOT_ICLOTHING, ITEM_SLOT_EARS)

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

	for(var/obj/item/thing in H.GetAllContents())
		thing.AddElement(/datum/element/vanish_on_drop)

///CLIP
/datum/outfit/ctf/clip
	name = "CTF Base Outfit (Minutemen)"
	head = /obj/item/clothing/head/helmet/bulletproof/x11/clip
	suit = /obj/item/clothing/suit/armor/vest/bulletproof
	uniform = /obj/item/clothing/under/clip/minutemen

/datum/outfit/ctf/clip/rifleman
	name = "CTF Rifleman (Minutemen)"
	suit_store = /obj/item/gun/ballistic/automatic/assault/cm82
	belt = /obj/item/storage/belt/military/clip/cm82/ctf
	icon_state = "rifleman_clip"
	class_description = "A standard CLIP infantry, equipped with a CM-82 assault rifle and frag grenade."

/datum/outfit/ctf/clip/engineer
	name = "CTF Engineer (Minutemen)"
	suit_store = /obj/item/gun/ballistic/automatic/smg/cm5
	belt = /obj/item/storage/belt/military/clip/cm5/ctf
	gloves = /obj/item/clothing/gloves/color/yellow
	glasses = /obj/item/clothing/glasses/welding
	accessory = /obj/item/clothing/accessory/armband/engine
	back = /obj/item/storage/backpack/satchel/eng
	backpack_contents = list(
		/obj/item/grenade/c4 = 2,
		/obj/item/crowbar/red,
		/obj/item/weldingtool/electric,
		/obj/item/extinguisher,
		/obj/item/stack/rods/twentyfive,
		/obj/item/stack/sheet/mineral/wood/twentyfive)
	icon_state = "engineer_clip"
	class_description = "A CLIP combat engineer, equipped with a CM-5 SMG and various engineering supplies such as C4, materials, and a barrier grenade."

/datum/outfit/ctf/clip/marksman
	name = "CTF Marksman (Minutemen)"
	suit_store = /obj/item/gun/ballistic/automatic/marksman/f4
	belt = /obj/item/storage/belt/military/clip/f4/ctf
	neck = /obj/item/binoculars
	suit = null
	head = /obj/item/clothing/head/clip
	icon_state = "marksman_clip"
	class_description = "A long-ranged CLIP specialist, equipped with an F4 marksman rifle, as well as a smoke grenade. Less armored."

/datum/outfit/ctf/clip/medic
	name = "CTF Medic (Minutemen)"
	suit_store = /obj/item/gun/ballistic/automatic/smg/cm5
	belt = /obj/item/storage/belt/medical/webbing/clip/ctf
	gloves = /obj/item/clothing/gloves/color/latex/nitrile
	accessory = /obj/item/clothing/accessory/armband/medblue
	icon_state = "medic_clip"
	class_description = "A CLIP combat medic, equipped with a CM-5 SMG and a fast-acting hypospray to heal teammates."

/datum/outfit/ctf/clip/breacher
	name = "CTF Breacher (Minutemen)"
	suit = /obj/item/clothing/suit/armor/vest/marine/heavy
	suit_store = /obj/item/gun/ballistic/shotgun/cm15
	belt = /obj/item/storage/belt/military/clip/cm15/ctf
	head = /obj/item/clothing/head/helmet/riot/clip
	icon_state = "breacher_clip"
	class_description = "A slow, but fully armored CLIP breacher, equipped with a CM-15 automatic shotgun and flashbang for close quarters combat."

/datum/outfit/ctf/clip/specialist
	name = "CTF Specialist (Minutemen)"
	suit = /obj/item/clothing/suit/bio_suit/bard/heavy
	suit_store = /obj/item/gun/energy/kalix/clip
	belt = /obj/item/storage/belt/military/clip/alt/ecm6/ctf
	mask = /obj/item/clothing/mask/gas/clip
	head = /obj/item/clothing/head/bio_hood/bard/armored
	icon_state = "specialist_clip"
	class_description = "A unique CLIP specialist, equipped with a window-piercing ECM-6 carbine and incendiary grenades."



///FRONTIERSMEN
/datum/outfit/ctf/frontiersmen
	name = "CTF Base Outfit (Frontiersmen)"
	head = /obj/item/clothing/head/helmet/bulletproof/x11/frontier
	suit = /obj/item/clothing/suit/armor/vest/bulletproof/frontier
	uniform = /obj/item/clothing/under/frontiersmen

/datum/outfit/ctf/frontiersmen/rifleman
	name = "CTF Rifleman (Frontiersmen)"
	suit_store = /obj/item/gun/ballistic/automatic/assault/skm
	belt = /obj/item/storage/belt/security/military/frontiersmen/skm_ammo/ctf
	icon_state = "rifleman_frontier"
	class_description = "A standard Frontiersmen grunt, equipped with an SKM assault rifle and frag grenade."

/datum/outfit/ctf/frontiersmen/engineer
	name = "CTF Engineer (Frontiersmen)"
	suit_store = /obj/item/gun/ballistic/automatic/pistol/spitter
	belt = /obj/item/storage/belt/security/military/frontiersmen/spitter_ammo/ctf
	gloves = /obj/item/clothing/gloves/color/yellow
	glasses = /obj/item/clothing/glasses/welding
	accessory = /obj/item/clothing/accessory/armband/engine
	back = /obj/item/storage/backpack/satchel/eng
	backpack_contents = list(
		/obj/item/grenade/c4 = 2,
		/obj/item/crowbar/red,
		/obj/item/weldingtool/electric,
		/obj/item/extinguisher,
		/obj/item/stack/rods/twentyfive,
		/obj/item/stack/sheet/mineral/wood/twentyfive)
	icon_state = "engineer_frontier"
	class_description = "A Frontiersmen technician, equipped with a Spitter SMG and various engineering supplies such as C4, materials, and a barrier grenade."

/datum/outfit/ctf/frontiersmen/marksman
	name = "CTF Marksman (Frontiersmen)"
	suit_store = /obj/item/gun/ballistic/automatic/marksman/f4/indie
	belt = /obj/item/storage/belt/security/military/frontiersmen/f3_ammo/ctf
	neck = /obj/item/binoculars
	suit = null
	head = /obj/item/clothing/head/beret/sec/frontier
	icon_state = "marksman_frontier"
	class_description = "A long-ranged Frontiersmen operative, equipped with an F3 marksman rifle, as well as a smoke grenade, but with less armor."

/datum/outfit/ctf/frontiersmen/medic
	name = "CTF Medic (Frontiersmen)"
	suit_store = /obj/item/gun/ballistic/automatic/pistol/spitter
	belt = /obj/item/storage/belt/medical/webbing/frontiersmen/ctf
	gloves = /obj/item/clothing/gloves/color/latex/nitrile
	accessory = /obj/item/clothing/accessory/armband/medblue
	icon_state = "medic_frontier"
	class_description = "A Frontiersmen combat medic, equipped with a Spitter SMG and a fast-acting hypospray to heal teammates."

/datum/outfit/ctf/frontiersmen/breacher
	name = "CTF Breacher (Frontiersmen)"
	suit = /obj/item/clothing/suit/armor/vest/marine/heavy
	suit_store = /obj/item/gun/ballistic/shotgun/automatic/slammer
	belt = /obj/item/storage/belt/security/military/frontiersmen/slammer_ammo/ctf
	head = /obj/item/clothing/head/helmet/frontier
	icon_state = "breacher_frontier"
	class_description = "A slow, but fully armored Frontiersmen close-quarters combatant, equipped with a Slammer shotgun and flashbang for clearing rooms."

/datum/outfit/ctf/frontiersmen/specialist
	name = "CTF Specialist (Frontiersmen)"
	suit = /obj/item/clothing/suit/armor/frontier/fireproof
	suit_store = /obj/item/gun/energy/laser/wasp
	belt = /obj/item/storage/belt/security/military/frontiersmen/wasp_ammo/ctf
	mask = /obj/item/clothing/mask/gas/frontiersmen
	uniform = /obj/item/clothing/under/frontiersmen/fireproof
	icon_state = "specialist_frontier"
	class_description = "A unique Frontiersmen operative, equipped with a window-penetrating Wasp laser SMG and incendiary grenades."



