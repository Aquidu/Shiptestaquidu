
/obj/item/clothing/under/rank/civilian/mime
	name = "mime's outfit"
	desc = "It's not very colourful."
	icon_state = "mime"
	item_state = "mime"

/obj/item/clothing/under/rank/civilian/mime/skirt
	name = "mime's skirt"
	desc = "It's not very colourful."
	icon_state = "mime_skirt"
	item_state = "mime"
	body_parts_covered = CHEST|GROIN|ARMS

	supports_variations = DIGITIGRADE_VARIATION_NO_NEW_ICON | VOX_VARIATION

/obj/item/clothing/under/rank/civilian/mime/sexy
	name = "sexy mime outfit"
	desc = "The only time when you DON'T enjoy looking at someone's rack."
	icon_state = "sexymime"
	item_state = "sexymime"
	body_parts_covered = CHEST|GROIN|LEGS


/obj/item/clothing/under/rank/civilian/clown
	name = "clown suit"
	desc = "<i>'HONK!'</i>"
	icon_state = "clown"
	item_state = "clown"

/obj/item/clothing/under/rank/civilian/clown/blue
	name = "blue clown suit"
	desc = "<i>'BLUE HONK!'</i>"
	icon_state = "blueclown"
	item_state = "blueclown"


/obj/item/clothing/under/rank/civilian/clown/green
	name = "green clown suit"
	desc = "<i>'GREEN HONK!'</i>"
	icon_state = "greenclown"
	item_state = "greenclown"


/obj/item/clothing/under/rank/civilian/clown/yellow
	name = "yellow clown suit"
	desc = "<i>'YELLOW HONK!'</i>"
	icon_state = "yellowclown"
	item_state = "yellowclown"


/obj/item/clothing/under/rank/civilian/clown/purple
	name = "purple clown suit"
	desc = "<i>'PURPLE HONK!'</i>"
	icon_state = "purpleclown"
	item_state = "purpleclown"


/obj/item/clothing/under/rank/civilian/clown/orange
	name = "orange clown suit"
	desc = "<i>'ORANGE HONK!'</i>"
	icon_state = "orangeclown"
	item_state = "orangeclown"


/obj/item/clothing/under/rank/civilian/clown/rainbow
	name = "rainbow clown suit"
	desc = "<i>'R A I N B O W HONK!'</i>"
	icon_state = "rainbowclown"
	item_state = "rainbowclown"


/obj/item/clothing/under/rank/civilian/clown/jester
	name = "jester suit"
	desc = "A jolly dress, well suited to entertain your master, nuncle."
	icon_state = "jester"


/obj/item/clothing/under/rank/civilian/clown/jester/alt
	icon_state = "jester2"

/obj/item/clothing/under/rank/civilian/clown/sexy
	name = "sexy-clown suit"
	desc = "It makes you look HONKable!"
	icon_state = "sexyclown"
	item_state = "sexyclown"


/obj/item/clothing/under/rank/civilian/clown/Initialize()
	. = ..()
	AddComponent(/datum/component/squeak, list('sound/items/bikehorn.ogg'=1), 50, falloff_exponent = 20) //die off quick please
