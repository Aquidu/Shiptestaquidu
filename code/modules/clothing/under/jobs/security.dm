/*
 * Contains:
 *		Security Officer
 *		Detective
 *		Brig Physician
 *		Warden
 *		Head of Security
 *		Prisoner
 *		Misc Sec Uniforms
 */

/*
 * Security
 */

/obj/item/clothing/under/rank/security
	icon = 'icons/obj/clothing/under/security.dmi'
	mob_overlay_icon = 'icons/mob/clothing/under/security.dmi'

// Security Officer //
/obj/item/clothing/under/rank/security/officer
	name = "security jumpsuit"
	desc = "A tactical security jumpsuit for officers."
	icon_state = "security"
	item_state = "gy_suit"
	armor = list("melee" = 0, "bullet" = 0, "laser" = 0,"energy" = 0, "bomb" = 0, "bio" = 0, "rad" = 0, "fire" = 30, "acid" = 30)
	strip_delay = 50
	roll_sleeves = TRUE
	sensor_mode = SENSOR_COORDS
	random_sensor = FALSE

/obj/item/clothing/under/rank/security/officer/skirt
	name = "security jumpskirt"
	desc = "A \"tactical\" security jumpsuit with the legs replaced by a skirt."
	icon_state = "security_skirt"
	body_parts_covered = CHEST|GROIN|ARMS
	supports_variations = DIGITIGRADE_VARIATION_NO_NEW_ICON

/obj/item/clothing/under/rank/security/officer/nt
	name = "red security jumpsuit"
	desc = "A tactical security jumpsuit for officers complete with a Nanotrasen belt buckle."
	icon_state = "rsecurity"
	item_state = "r_suit"

/obj/item/clothing/under/rank/security/officer/nt/skirt
	name = "red security jumpskirt"
	desc = "A \"tactical\" security jumpsuit with the legs replaced by a skirt."
	icon_state = "rsecurity_skirt"
	body_parts_covered = CHEST|GROIN|ARMS
	supports_variations = DIGITIGRADE_VARIATION_NO_NEW_ICON

// Detective//
/obj/item/clothing/under/rank/security/detective
	name = "hard-worn suit"
	desc = "Someone who wears this means business."
	icon_state = "detective"
	item_state = "det"
	strip_delay = 50
	roll_sleeves = TRUE
	sensor_mode = 3
	random_sensor = FALSE

/obj/item/clothing/under/rank/security/detective/skirt
	name = "detective's suitskirt"
	desc = "Someone who wears this means business."
	icon_state = "detective_skirt"
	body_parts_covered = CHEST|GROIN|ARMS
	supports_variations = DIGITIGRADE_VARIATION_NO_NEW_ICON

/obj/item/clothing/under/rank/security/detective/grey
	name = "noir suit"
	desc = "A hard-boiled private investigator's grey suit, complete with tie clip."
	icon_state = "greydet"
	item_state = "greydet"

/obj/item/clothing/under/rank/security/detective/grey/skirt
	name = "noir suitskirt"
	desc = "A hard-boiled private investigator's grey suitskirt, complete with tie clip."
	icon_state = "greydet_skirt"
	body_parts_covered = CHEST|GROIN|ARMS
	supports_variations = DIGITIGRADE_VARIATION_NO_NEW_ICON

// Brig Physician //
/obj/item/clothing/under/rank/security/brig_phys
	name = "brig physician jumpsuit"
	desc = "A umpsuit worn by practitioners entrusted to the care of prisoners around the frontier."
	icon_state = "brig_phys"
	roll_sleeves = TRUE

/obj/item/clothing/under/rank/security/brig_phys/skirt
	name = "brig physician jumpskirt"
	desc = "A jumpskirt worn by practitioners entrusted to the care of prisoners around the frontier."
	icon_state = "brig_phys_skirt"
	body_parts_covered = CHEST|GROIN|ARMS
	roll_sleeves = FALSE
	supports_variations = DIGITIGRADE_VARIATION_NO_NEW_ICON

/obj/item/clothing/under/rank/security/brig_phys/nt
	name = "security medic's uniform"
	desc = "A uniform worn by members of Nanotrasen's Asset Protection Medical Corps."
	icon_state = "security_medic"
	item_state = "r_suit"
	mob_overlay_state = "rbrig_phys"

/obj/item/clothing/under/rank/security/brig_phys/nt/skirt
	name = "security medic's uniform"
	desc = "A uniform with a skirt, worn by members of Nanotrasen's Asset Protection Medical Corps."
	icon_state = "security_medic_skirt"
	mob_overlay_state = "rbrig_phys_skirt"
	body_parts_covered = CHEST|GROIN|ARMS
	supports_variations = DIGITIGRADE_VARIATION_NO_NEW_ICON


// Warden //
/obj/item/clothing/under/rank/security/warden
	name = "warden's security suit"
	desc = "A formal security suit for wardens."
	icon_state = "warden"
	armor = list("melee" = 0, "bullet" = 0, "laser" = 0,"energy" = 0, "bomb" = 0, "bio" = 0, "rad" = 0, "fire" = 30, "acid" = 30)
	strip_delay = 50
	roll_sleeves = TRUE
	sensor_mode = 3
	random_sensor = FALSE

/obj/item/clothing/under/rank/security/warden/skirt
	name = "warden's suitskirt"
	desc = "A formal security suitskirt for wardens."
	icon_state = "warden_skirt"
	body_parts_covered = CHEST|GROIN|ARMS
	supports_variations = DIGITIGRADE_VARIATION_NO_NEW_ICON

/obj/item/clothing/under/rank/security/warden/nt
	name = "warden's red security suit"
	desc = "A formal security suit for wardens, complete with Nanotrasen belt buckle."
	icon_state = "rwarden"
	item_state = "r_suit"

/obj/item/clothing/under/rank/security/warden/nt/skirt
	name = "warden's red suitskirt"
	desc = "A formal security suitskirt for wardens, complete with Nanotrasen belt buckle."
	icon_state = "rwarden_skirt"
	item_state = "r_suit"
	body_parts_covered = CHEST|GROIN|ARMS
	supports_variations = DIGITIGRADE_VARIATION_NO_NEW_ICON

// Head of Security //
/obj/item/clothing/under/rank/security/head_of_security
	name = "head of security's jumpsuit"
	desc = "A security jumpsuit decorated for those few with the dedication to achieve the position of Head of Security."
	icon_state = "hos"
	armor = list("melee" = 0, "bullet" = 0, "laser" = 0,"energy" = 0, "bomb" = 0, "bio" = 0, "rad" = 0, "fire" = 50, "acid" = 50)
	strip_delay = 60
	roll_sleeves = TRUE
	sensor_mode = 3
	random_sensor = FALSE

/obj/item/clothing/under/rank/security/head_of_security/skirt
	name = "head of security's jumpskirt"
	desc = "A security jumpskirt decorated for those few with the dedication to achieve the position of Head of Security."
	icon_state = "hos_skirt"
	body_parts_covered = CHEST|GROIN|ARMS
	roll_sleeves = FALSE
	supports_variations = DIGITIGRADE_VARIATION_NO_NEW_ICON

/obj/item/clothing/under/rank/security/head_of_security/alt
	name = "head of security's turtleneck"
	desc = "A stylish alternative to the normal head of security jumpsuit, complete with tactical pants."
	icon_state = "hosalt"
	item_state = "bl_suit"

/obj/item/clothing/under/rank/security/head_of_security/alt/skirt
	name = "head of security's turtleneck skirt"
	desc = "A stylish alternative to the normal head of security jumpsuit, complete with a tactical skirt."
	icon_state = "hosalt_skirt"
	item_state = "bl_suit"
	body_parts_covered = CHEST|GROIN|ARMS
	supports_variations = DIGITIGRADE_VARIATION_NO_NEW_ICON

/obj/item/clothing/under/rank/security/head_of_security/nt
	name = "red head of security's jumpsuit"
	icon_state = "rhos"
	item_state = "r_suit"

/obj/item/clothing/under/rank/security/head_of_security/nt/skirt
	name = "head of security's red jumpskirt"
	desc = "A security jumpskirt decorated for those few with the dedication to achieve the position of Head of Security."
	icon_state = "rhos_skirt"
	body_parts_covered = CHEST|GROIN|ARMS
	supports_variations = DIGITIGRADE_VARIATION_NO_NEW_ICON

/obj/item/clothing/under/rank/security/head_of_security/parade
	name = "head of security's parade uniform"
	desc = "A male head of security's luxury-wear, for special occasions."
	icon_state = "hos_parade_male"
	roll_sleeves = FALSE

/obj/item/clothing/under/rank/security/head_of_security/parade/female
	name = "head of security's parade uniform"
	desc = "A female head of security's luxury-wear, for special occasions."
	icon_state = "hos_parade_fem"
	roll_sleeves = FALSE

// Prisoner //
/obj/item/clothing/under/rank/prisoner
	name = "prison jumpsuit"
	desc = "It's standardised prisoner-wear. Its suit sensors are stuck in the \"Fully On\" position."
	icon = 'icons/obj/clothing/under/security.dmi'
	icon_state = "prisoner"
	item_state = "o_suit"
	mob_overlay_icon = 'icons/mob/clothing/under/security.dmi'
	roll_down = TRUE
	has_sensor = LOCKED_SENSORS
	sensor_mode = SENSOR_COORDS
	random_sensor = FALSE

/obj/item/clothing/under/rank/prisoner/skirt
	name = "prison jumpskirt"
	desc = "It's standardised prisoner-wear. Its suit sensors are stuck in the \"Fully On\" position."
	icon_state = "prisoner_skirt"
	item_state = "o_suit"
	body_parts_covered = CHEST|GROIN|ARMS
	roll_down = FALSE
	supports_variations = DIGITIGRADE_VARIATION_NO_NEW_ICON

/obj/item/clothing/under/rank/prisoner/protected_custody
	name = "protected custody jumpsuit"
	desc = "It's standardised prisoner-wear worn by those in protected custody. Its suit sensors are stuck in the \"Fully On\" position."
	icon_state = "protected_custody"

/obj/item/clothing/under/rank/prisoner/protected_custody/skirt
	name = "protected custody jumpskirt"
	desc = "It's standardised prisoner-wear worn by those in protected custody. Its suit sensors are stuck in the \"Fully On\" position."
	icon_state = "protected_custody_skirt"
	supports_variations = DIGITIGRADE_VARIATION_NO_NEW_ICON

// Non-official //
/obj/item/clothing/under/rank/security/constable
	name = "constable outfit"
	desc = "A british looking outfit."
	icon_state = "constable"
	item_state = "constable"
	custom_price = 200

/obj/item/clothing/under/rank/security/officer/beatcop
	name = "space police uniform"
	desc = "A police uniform often found in the lines at donut shops."
	icon_state = "spacepolice_families"
	item_state = "spacepolice_families"

/obj/item/clothing/under/rank/security/officer/blueshirt
	name = "blue shirt and tie"
	desc = "I'm a little busy right now, Calhoun."
	icon_state = "blueshift"
	item_state = "blueshift"

/obj/item/clothing/under/rank/security/officer/mallcop
	name = "NT mall cop uniform"
	desc = "The radio and badge are sewn on. What a crappy knock off! Secway not included."
	icon_state = "mallcop"

/obj/item/clothing/under/rank/security/officer/military
	name = "tactical combat uniform"
	desc = "A dark colored uniform worn by private military forces."
	icon_state = "military"
	item_state = "bl_suit"
	armor = list("melee" = 0, "bullet" = 0, "laser" = 0,"energy" = 0, "bomb" = 0, "bio" = 0, "fire" = 50, "acid" = 40)

/obj/item/clothing/under/rank/security/officer/military/eng
	name = "tactical engineering uniform"
	desc = "A dark colored uniform worn by private military engineers."
	icon_state = "military_eng"

/obj/item/clothing/under/rank/security/officer/camo
	name = "fatigues"
	desc = "A combat uniform most often worn by mercenaries and TPLRC soldiers. Features polychromatic design to adjust to different environments."
	icon_state = "camo"
	item_state = "fatigues"

	unique_reskin = list("Urban" = "camo",
		"Desert" = "camo_desert",
		"Woodland" = "camo_woodland",
		"Snow" = "camo_snow",
		)

/obj/item/storage/belt/military/ComponentInitialize()
	. = ..()
	AddElement(/datum/element/update_icon_updates_onmob)
