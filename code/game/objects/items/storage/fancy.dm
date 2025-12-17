/*
 * The 'fancy' path is for objects like donut boxes that show how many items are in the storage item on the sprite itself
 * .. Sorry for the shitty path name, I couldnt think of a better one.
 *
 * Contains:
 *		Donut Box
 *		Egg Box
 *		Candle Box
 *		Cigarette Box
 *		Cigar Case
 *		Heart Shaped Box w/ Chocolates
 */

/obj/item/storage/fancy
	icon = 'icons/obj/food/containers.dmi'
	icon_state = "donutbox"
	base_icon_state = "donutbox"
	resistance_flags = FLAMMABLE
	/// Used by examine to report what this thing is holding.
	var/contents_tag = "errors"
	/// What type of thing to fill this storage with.
	var/spawn_type = null
	/// Whether the container is open or not
	var/is_open = FALSE

/obj/item/storage/fancy/PopulateContents()
	if(!spawn_type)
		return
	var/datum/component/storage/STR = GetComponent(/datum/component/storage)
	if(!spawn_type)
		return
	for(var/i = 1 to STR.max_items)
		new spawn_type(src)

/obj/item/storage/fancy/update_icon_state()
	icon_state = "[base_icon_state][is_open ? contents.len : null]"
	return ..()

/obj/item/storage/fancy/examine(mob/user)
	. = ..()
	if(!is_open)
		return
	if(length(contents) == 1)
		. += "There is one [contents_tag] left."
	else
		. += "There are [contents.len <= 0 ? "no" : "[contents.len]"] [contents_tag]s left."

/obj/item/storage/fancy/attack_self(mob/user)
	is_open = !is_open
	update_appearance()
	. = ..()

/obj/item/storage/fancy/Exited()
	. = ..()
	is_open = TRUE
	update_appearance()

/obj/item/storage/fancy/Entered()
	. = ..()
	is_open = TRUE
	update_appearance()

#define DONUT_INBOX_SPRITE_WIDTH 3

/*
 * Donut Box
 */

/obj/item/storage/fancy/donut_box
	name = "donut box"
	desc = "Mmm. Donuts."
	icon = 'icons/obj/food/donuts.dmi'
	icon_state = "donutbox_inner"
	base_icon_state = "donutbox"
	spawn_type = /obj/item/food/donut
	is_open = TRUE
	appearance_flags = KEEP_TOGETHER
	contents_tag = "donut"

/obj/item/storage/fancy/donut_box/ComponentInitialize()
	. = ..()
	var/datum/component/storage/STR = GetComponent(/datum/component/storage)
	STR.max_items = 6
	STR.set_holdable(list(/obj/item/food/donut))

/obj/item/storage/fancy/donut_box/PopulateContents()
	. = ..()
	update_appearance()

/obj/item/storage/fancy/donut_box/update_icon_state()
	. = ..()
	icon_state = "[base_icon_state][is_open ? "_inner" : null]"

/obj/item/storage/fancy/donut_box/update_overlays()
	. = ..()

	if(!is_open)
		return

	var/donuts = 0

	for(var/_donut in contents)
		var/obj/item/food/donut/donut = _donut
		if (!istype(donut))
			continue

		. += image(icon = initial(icon), icon_state = donut.in_box_sprite(), pixel_x = donuts * DONUT_INBOX_SPRITE_WIDTH)
		donuts += 1

	. += image(icon = initial(icon), icon_state = "[base_icon_state]_top")

#undef DONUT_INBOX_SPRITE_WIDTH

/*
 * Egg Box
 */

/obj/item/storage/fancy/egg_box
	icon = 'icons/obj/food/containers.dmi'
	item_state = "eggbox"
	icon_state = "eggbox"
	base_icon_state = "eggbox"
	lefthand_file = 'icons/mob/inhands/misc/food_lefthand.dmi'
	righthand_file = 'icons/mob/inhands/misc/food_righthand.dmi'
	name = "egg box"
	desc = "A carton for containing eggs."
	spawn_type = /obj/item/food/egg
	contents_tag = "egg"

/obj/item/storage/fancy/egg_box/ComponentInitialize()
	. = ..()
	var/datum/component/storage/STR = GetComponent(/datum/component/storage)
	STR.max_items = 12
	STR.set_holdable(list(/obj/item/food/egg))

/obj/item/storage/fancy/egg_box/update_icon_state()
	. = ..()
	icon_state = "[base_icon_state][is_open ? "_open" : null]"

/obj/item/storage/fancy/egg_box/update_overlays()
	. = ..()
	cut_overlays()
	if(!is_open)
		return
	var/egg_count = 0
	for(var/obj/item/food/egg as anything in contents)
		egg_count++
		if(!egg)
			return
		var/image/current_huevo = image(icon = icon, icon_state = "eggbox_eggoverlay")
		if(egg_count <= 6) //less than 6 eggs
			current_huevo.pixel_x = (3*(egg_count-1))
		else //if more than 6, make an extra row
			current_huevo.pixel_x = (3*(egg_count-7)) //-7 to 'reset' it
			current_huevo.pixel_y = -3
		add_overlay(current_huevo)


/*
 * Candle Box
 */

/obj/item/storage/fancy/candle_box
	name = "candle pack"
	desc = "A pack of red candles."
	icon = 'icons/obj/candle.dmi'
	icon_state = "candlebox5"
	base_icon_state = "candlebox"
	item_state = "candlebox5"
	throwforce = 2
	slot_flags = ITEM_SLOT_BELT
	spawn_type = /obj/item/candle
	is_open = TRUE
	contents_tag = "candle"

/obj/item/storage/fancy/candle_box/ComponentInitialize()
	. = ..()
	var/datum/component/storage/STR = GetComponent(/datum/component/storage)
	STR.max_items = 5

/obj/item/storage/fancy/candle_box/attack_self(mob_user)
	return

////////////
//CIG PACK//
////////////
/obj/item/storage/fancy/cigarettes
	name = "\improper Uplift Common packet"
	desc = "A pack of Uplift Intergalactic's flagship cigarette, sometimes called \"The Smoke That Won The Galaxy.\" Their cheap production cost and low tobacco quality standards made them extremely easy to mass-produce throughout the galaxy, leading to it's current reputation of the most popular cigarette brand."
	icon = 'icons/obj/cigarettes.dmi'
	base_icon_state = "cig"
	icon_state = "cig"
	item_state = "cigpacket"
	w_class = WEIGHT_CLASS_TINY
	throwforce = 0
	slot_flags = ITEM_SLOT_BELT
	spawn_type = /obj/item/clothing/mask/cigarette/space_cigarette
	var/candy = FALSE //for cigarette overlay
	custom_price = 5
	contents_tag = "cigarette"

/obj/item/storage/fancy/cigarettes/ComponentInitialize()
	. = ..()
	var/datum/component/storage/STR = GetComponent(/datum/component/storage)
	STR.max_items = 6
	STR.set_holdable(list(/obj/item/clothing/mask/cigarette, /obj/item/lighter))

/obj/item/storage/fancy/cigarettes/examine(mob/user)
	. = ..()
	. += span_notice("Alt-click to extract contents.")

/obj/item/storage/fancy/cigarettes/afterattack_secondary(atom/target, mob/user, proximity_flag, click_parameters)
	. = ..()
	if(!proximity_flag)
		return
	if(ishuman(target) && contents.len)
		var/mob/living/carbon/human/bumming_a_smoke = target
		if(do_after(user, 15, bumming_a_smoke, show_progress = FALSE))
			var/obj/item/clothing/mask/cigarette/british_slang = locate(/obj/item/clothing/mask/cigarette) in contents
			if(british_slang)
				SEND_SIGNAL(src, COMSIG_TRY_STORAGE_TAKE, british_slang, user)
				if(bumming_a_smoke.equip_to_slot_if_possible(british_slang, ITEM_SLOT_MASK, disable_warning=TRUE))
					user.visible_message(span_notice("[user] puts a cigarette in [bumming_a_smoke]'s lips"), span_notice("You put a cigarette in [bumming_a_smoke]'s lips"))
				else
					bumming_a_smoke.put_in_hand(british_slang)
					user.visible_message(span_notice("[user] puts a cigarette in [bumming_a_smoke]'s hand"), span_notice("You put a cigarette in [bumming_a_smoke]'s hands"))
				contents -= british_slang

/obj/item/storage/fancy/cigarettes/attack_self_secondary(mob/living/carbon/user)
	if(!istype(user) || !user.canUseTopic(src, BE_CLOSE, ismonkey(user)))
		return
	get_cigarette(user)

/obj/item/storage/fancy/cigarettes/AltClick(mob/living/carbon/user)
	. = ..()
	var/obj/item/lighter/the_zippo = locate(/obj/item/lighter) in contents
	if(the_zippo)
		SEND_SIGNAL(src, COMSIG_TRY_STORAGE_TAKE, the_zippo, user)
		user.put_in_hands(the_zippo)
		contents -= the_zippo
	else
		get_cigarette(user)

/obj/item/storage/fancy/cigarettes/proc/get_cigarette(mob/living/carbon/user)
	var/obj/item/clothing/mask/cigarette/british_slang = locate(/obj/item/clothing/mask/cigarette) in contents
	if(british_slang)
		SEND_SIGNAL(src, COMSIG_TRY_STORAGE_TAKE, british_slang, user)
		user.put_in_hands(british_slang)
		contents -= british_slang
		to_chat(user, span_notice("You take \a [british_slang] out of the pack."))
	else
		to_chat(user, span_notice("There are no [contents_tag]s left in the pack."))


/obj/item/storage/fancy/cigarettes/update_icon_state()
	. = ..()
	icon_state = "[base_icon_state][contents.len ? null : "_empty"]"
	return

/obj/item/storage/fancy/cigarettes/update_overlays()
	. = ..()
	if(!is_open || !contents.len)
		return

	. += "[icon_state]_open"
	var/cig_position = 1
	for(var/C in contents)
		var/mutable_appearance/inserted_overlay = mutable_appearance(icon)

		if(istype(C, /obj/item/lighter/greyscale))
			inserted_overlay.icon_state = "lighter_in"
		else if(istype(C, /obj/item/lighter))
			inserted_overlay.icon_state = "zippo_in"
		else if(candy)
			inserted_overlay.icon_state = "candy"
		else
			inserted_overlay.icon_state = "cigarette"

		inserted_overlay.icon_state = "[inserted_overlay.icon_state]_[cig_position]"
		. += inserted_overlay
		cig_position++

/obj/item/storage/fancy/cigarettes/attack(mob/living/carbon/target, mob/living/carbon/user)
	if(!istype(target))
		return

	var/obj/item/clothing/mask/cigarette/cig = locate() in contents
	if(!cig)
		to_chat(user, span_notice("There are no [contents_tag]s left in the pack."))
		return
	if(target != user || !contents.len || user.wear_mask)
		return ..()

	SEND_SIGNAL(src, COMSIG_TRY_STORAGE_TAKE, cig, target)
	target.equip_to_slot_if_possible(cig, ITEM_SLOT_MASK)
	contents -= cig
	to_chat(user, span_notice("You take \a [cig] out of the pack."))
	return

/obj/item/storage/fancy/cigarettes/dromedaryco
	name = "\improper Dromedary Straws packet"
	desc = "A pack of Dromedary Corporation's marketed \"survival\" cigarettes. Normally known for their camping and survival gear, Dromedary Co. couldn't keep their hands out of the lucrative tobacco market, debuting their \"Straws\" in 463 FSC. Claiming them as \"survival cigarettes,\" the packaging proudly brags about the hydrating effects of each cigarette. Despite the otherwise lackluster quality, they proved popular with many workers of labor-intensive jobs, especially in the Frontier."
	icon_state = "dromedary"
	base_icon_state = "dromedary"
	spawn_type = /obj/item/clothing/mask/cigarette/dromedary
	custom_price = 10

/obj/item/storage/fancy/cigarettes/cigpack_uplift
	name = "\improper Uplift Smooth packet"
	desc = "A pack of Uplift Intergalactic's next-generation cigarette, Uplift Smooth cigarettes attempt to improve on the quality of Uplift Common by adding menthol as a flavor, masking the lower-quality tobacco. The side of the package shows a step-by-step diagram on how to \"properly\" enjoy an Uplift Smooth, with instructions in multiple languages. While not as popular as their flagship brand, Uplift Smooth has been rapidly growing in popularity in the Frontier since the end of the Inter-Corporate Wars."
	icon_state = "uplift"
	base_icon_state = "uplift"
	spawn_type = /obj/item/clothing/mask/cigarette/uplift
	custom_price = 10

/obj/item/storage/fancy/cigarettes/cigpack_robust
	name = "\improper Kingpin Heavy packet"
	desc = "A packet of Kingpin Tobacco's Heavy brand cigarettes. One of the few remaining unfiltered cigarette brands available for purchase, Kingpin Heavy cigarettes continue to sell due to the Pan-Gezenan Federation's lax restrictions on their tobacco export. While many other polities have enacted their own restrictions, the nature of the Frontier allows these tar-sticks to be sold easily. Marketed primarily to the macho and masculine, the packet's slogan proudly states: \"You ain't a KING 'til you smoke KINGPIN!\""
	icon_state = "robust"
	base_icon_state = "robust"
	spawn_type = /obj/item/clothing/mask/cigarette/robust
	custom_price = 10

/obj/item/storage/fancy/cigarettes/cigpack_robustgold
	name = "\improper Kingpin Elite packet"
	desc = "A packet of Kingpin Tobacco's Elite brand cigarettes. One of their most expensive products, Kingpin Elite cigarettes are lined with gold dust, allowing the smoker's breath to glitter slightly when they exhale. Marketed to high-class socialites, Kingpin Elite cigarettes see more sales in the core regions of space, but a Frontier baron or warload using them to impress their peers or subordinates isn't unheard of."
	icon_state = "robustg"
	base_icon_state = "robustg"
	spawn_type = /obj/item/clothing/mask/cigarette/robustgold
	custom_price = 20

/obj/item/storage/fancy/cigarettes/cigpack_carp
	name = "\improper Uplift Classic packet"
	desc = "A packet of Uplift Classic cigarettes, manufactured by Uplift Intergalactic as a tribute to their company's first-generation cigarette, which was wrapped in cleaned carp skin. These new ones use a synthetic alternative, leading to hopefully less Carpotoxin poisoning, while still providing the fishy taste."
	icon_state = "carp"
	base_icon_state = "carp"
	spawn_type = /obj/item/clothing/mask/cigarette/carp
	custom_price = 10


/obj/item/storage/fancy/cigarettes/cigpack_syndicate
	name = "\improper Cybersun Combat Cigarettes packet"
	desc = "A packet of now-discontinued cigarettes manufactured by Cybersun Biodynamics for the Gorlex Marauders during the Inter-Corporate War. Probably helps you fight harder. Also probably bad for your long-term health."
	icon_state = "syndie"
	base_icon_state = "syndie"
	spawn_type = /obj/item/clothing/mask/cigarette/syndicate

/obj/item/storage/fancy/cigarettes/cigpack_midori
	name = "\improper Shafiti Tamaci packet"
	desc = "A packet of Shafiti Pharmaceuticals' Tamaci-brand cigarettes, rolled in a dried Siti leaf as opposed to standard paper. Marketed as lighter and environmentally-friendly, these nicotine rollies are popular alternatives to standard cigarettes preferred by many Tecetians, or the environmentally concious."
	icon_state = "midori"
	base_icon_state = "midori"
	spawn_type = /obj/item/clothing/mask/cigarette/rollie/nicotine
	custom_price = 10

/obj/item/storage/fancy/cigarettes/cigpack_candy
	name = "\improper Timmy's First Candy Smokes packet"
	desc = "Originally a joke gift, these sugar sticks gained a scary amount of popularity after several viral Intranet videos of pranksters handing them out to children went viral. Since then, the original production company has discontinuted the product, but that only served to spur on the production of more off-brands, some of which are rumored to be spiked with real nicotine. While mostly controlled in the Core, these sugar sticks are still easy to find in the Frontier."
	icon_state = "candy"
	base_icon_state = "candy"
	contents_tag = "candy cigarette"
	spawn_type = /obj/item/clothing/mask/cigarette/candy
	candy = TRUE

/obj/item/storage/fancy/cigarettes/cigpack_candy/Initialize()
	. = ..()
	if(prob(7))
		spawn_type = /obj/item/clothing/mask/cigarette/candy/nicotine //uh oh!

/obj/item/storage/fancy/cigarettes/cigpack_cannabis
	name = "\improper Freak Brothers' Special packet"
	desc = "A packet of Freak Brothers' Special brand joints. One of the few smoke brands based in-house in the Frontier, Freak Brothers' Special joints contain a Tecetian herb known for it's stimulating and relaxing effects. Due to practically no information being available on the Freak Brothers' production methods, or even where they're based, they have not been approved by any health organization, as a result rarely travel outside of the Frontier. Despite this, their often high quality combined with their rarity makes them often sought after."
	icon_state = "midori"
	base_icon_state = "midori"
	spawn_type = /obj/item/clothing/mask/cigarette/rollie/cannabis

/obj/item/storage/fancy/cigarettes/cigpack_mindbreaker
	name = "\improper Kingpin Extreme packet"
	desc = "A packet of recalled Kingpin Extreme brand blunts. These blunts, loaded with hallucinogenic drugs and compounds, were created and approved almost soley by Kingpin Tobacco's overbearingly controlling and powerful spokesperson, Yalaki-Bezha. Seeking to create the most powerful smokable ever, Bezha speed-ran getting the blunt created and produced before the company's leadership found out. Production was shut down fast and a recall was ordered, but several thousand packets still managed to escape, with most finding their way to unregulated pockets of space such as the Frontier."
	icon_state = "shadyjim"
	base_icon_state = "shadyjim"
	spawn_type = /obj/item/clothing/mask/cigarette/rollie/mindbreaker

/obj/item/storage/fancy/rollingpapers
	name = "rolling paper pack"
	desc = "A pack of Uplift brand rolling papers, cheaply made from pressed plant matter and treated with chemicals to burn better."
	w_class = WEIGHT_CLASS_TINY
	icon = 'icons/obj/cigarettes.dmi'
	icon_state = "cig_paper_pack"
	base_icon_state = "cig_paper_pack"
	contents_tag = "rolling paper"
	spawn_type = /obj/item/rollingpaper
	custom_price = 5

/obj/item/storage/fancy/rollingpapers/ComponentInitialize()
	. = ..()
	var/datum/component/storage/STR = GetComponent(/datum/component/storage)
	STR.max_items = 10
	STR.set_holdable(list(/obj/item/rollingpaper))

///Overrides to do nothing because fancy boxes are fucking insane.
/obj/item/storage/fancy/rollingpapers/update_icon_state()
	SHOULD_CALL_PARENT(FALSE)
	return

/obj/item/storage/fancy/rollingpapers/update_overlays()
	. = ..()
	if(!contents.len)
		. += "[base_icon_state]_empty"

/obj/item/storage/fancy/cigarettes/derringer
	name = "\improper Kingpin Heavy packet"
	desc = "A packet of Kingpin Tobacco's Heavy brand cigarettes. One of the few remaining unfiltered cigarette brands available for purchase, Kingpin Heavy cigarettes continue to sell due to the Pan-Gezenan Federation's lax restrictions on their tobacco export. While many other polities have enacted their own restrictions, the nature of the Frontier allows these tar-sticks to be sold easily. Marketed primarily to the macho and masculine, the packet's slogan proudly states: \"You ain't a KING 'til you smoke KINGPIN!\""
	icon_state = "robust"
	spawn_type = /obj/item/gun/ballistic/derringer/traitor

/obj/item/storage/fancy/cigarettes/derringer/ComponentInitialize()
	. = ..()
	var/datum/component/storage/STR = GetComponent(/datum/component/storage)
	STR.max_items = 6
	STR.set_holdable(list(/obj/item/clothing/mask/cigarette, /obj/item/lighter, /obj/item/gun/ballistic/derringer, /obj/item/ammo_casing/a357))

/obj/item/storage/fancy/cigarettes/derringer/AltClick(mob/living/carbon/user)
	if(!istype(user) || !user.canUseTopic(src, BE_CLOSE, ismonkey(user)))
		return
	var/obj/item/W = (locate(/obj/item/ammo_casing/a357) in contents) || (locate(/obj/item/clothing/mask/cigarette) in contents) //Easy access smokes and bullets
	if(W && contents.len > 0)
		SEND_SIGNAL(src, COMSIG_TRY_STORAGE_TAKE, W, user)
		user.put_in_hands(W)
		contents -= W
		to_chat(user, span_notice("You take \a [W] out of the pack."))
	else
		to_chat(user, span_notice("There are no items left in the pack."))

/obj/item/storage/fancy/cigarettes/derringer/PopulateContents()
	new spawn_type(src)
	new /obj/item/ammo_casing/a357(src)
	new /obj/item/ammo_casing/a357(src)
	new /obj/item/ammo_casing/a357(src)
	new /obj/item/ammo_casing/a357(src)
	new /obj/item/clothing/mask/cigarette/syndicate(src)

//For traitors with luck/class
/obj/item/storage/fancy/cigarettes/derringer/gold
	name = "\improper Kingpin Elite packet"
	desc = "A packet of Kingpin Tobacco's Elite brand cigarettes. One of their most expensive products, Kingpin Elite cigarettes are lined with gold dust, allowing the smoker's breath to glitter slightly when they exhale. Marketed to high-class socialites, Kingpin Elite cigarettes see more sales in the core regions of space, but a Frontier baron or warload using them to impress their peers or subordinates isn't unheard of."
	icon_state = "robustg"
	spawn_type = /obj/item/gun/ballistic/derringer/gold

/////////////
//CIGAR BOX//
/////////////

/obj/item/storage/fancy/cigarettes/cigars
	name = "\improper cigar case"
	desc = "A case of generic-brand cigars."
	icon = 'icons/obj/cigarettes.dmi'
	icon_state = "cigarcase"
	w_class = WEIGHT_CLASS_NORMAL
	base_icon_state = "cigarcase"
	spawn_type = /obj/item/clothing/mask/cigarette/cigar

/obj/item/storage/fancy/cigarettes/cigars/ComponentInitialize()
	. = ..()
	var/datum/component/storage/STR = GetComponent(/datum/component/storage)
	STR.max_items = 5
	STR.set_holdable(list(/obj/item/clothing/mask/cigarette/cigar))

/obj/item/storage/fancy/cigarettes/cigars/update_icon_state()
	. = ..()
	icon_state = "[base_icon_state][is_open ? "_open" : null]"

/obj/item/storage/fancy/cigarettes/cigars/update_overlays()
	. = ..()
	if(!is_open)
		return
	var/cigar_position = 1 //generate sprites for cigars in the box
	for(var/obj/item/clothing/mask/cigarette/cigar/smokes in contents)
		var/mutable_appearance/cigar_overlay = mutable_appearance(icon, "[smokes.icon_off]_[cigar_position]")
		. += cigar_overlay
		cigar_position++

/obj/item/storage/fancy/cigarettes/cigars/cohiba
	name = "\improper Kingpin cigar case"
	desc = "A case of Kingpin brand cigars imported straight from Kalixcis. Expensive and densely packed, but the strongest tobacco flavor you'll ever taste."
	icon_state = "cohibacase"
	base_icon_state = "cohibacase"
	spawn_type = /obj/item/clothing/mask/cigarette/cigar/cohiba

/obj/item/storage/fancy/cigarettes/cigars/havana
	name = "\improper Solarian cigar case"
	desc = "A case of expensive Solarian cigars imported straight from Terra. Uses all-natural, expertly grown tobacco for a luxurious taste."
	icon_state = "cohibacase"
	base_icon_state = "cohibacase"
	spawn_type = /obj/item/clothing/mask/cigarette/cigar/havana

/*
 * Heart Shaped Box w/ Chocolates
 */

/obj/item/storage/fancy/heart_box
	name = "heart-shaped box"
	desc = "A heart-shaped box for holding tiny chocolates."
	icon = 'icons/obj/food/containers.dmi'
	item_state = "chocolatebox"
	icon_state = "chocolatebox"
	base_icon_state = "chocolatebox"
	lefthand_file = 'icons/mob/inhands/misc/food_lefthand.dmi'
	righthand_file = 'icons/mob/inhands/misc/food_righthand.dmi'
	spawn_type = /obj/item/food/bonbon
	contents_tag = "chocolate"

/obj/item/storage/fancy/heart_box/ComponentInitialize()
	. = ..()
	var/datum/component/storage/STR = GetComponent(/datum/component/storage)
	STR.max_items = 8
	STR.set_holdable(list(/obj/item/food/bonbon))

/obj/item/storage/fancy/nugget_box
	name = "nugget box"
	desc = "A cardboard box used for holding chicken nuggies."
	icon = 'icons/obj/food/containers.dmi'
	icon_state = "nuggetbox"
	base_icon_state = "nuggetbox"
	contents_tag = "nugget"
	spawn_type = /obj/item/food/nugget

/obj/item/storage/fancy/nugget_box/ComponentInitialize()
	. = ..()
	var/datum/component/storage/STR = GetComponent(/datum/component/storage)
	STR.max_items = 6
	STR.set_holdable(list(/obj/item/food/nugget))
