/obj/item/blackmarket_uplink
	name = "Black Market Uplink"
	icon = 'icons/obj/blackmarket.dmi'
	icon_state = "uplink"
	desc = "A jury rigged uplink capable of accessing illicit or grey market vendors. There's a port on side for linking it to a LTSRBT for more practical shipping."

	// UI variables.
	var/viewing_category
	var/viewing_market
	var/selected_item
	var/buying

	/// How much money is inserted into the uplink.
	var/money = 0
	/// List of typepaths for "/datum/blackmarket_market"s that this uplink can access.
	var/list/accessible_markets = list(/datum/blackmarket_market/blackmarket)
	// Linked LTSRBT for uplink to send to.
	var/obj/machinery/ltsrbt/target

/obj/item/blackmarket_uplink/Initialize()
	. = ..()
	if(accessible_markets.len)
		viewing_market = accessible_markets[1]
		var/list/categories = SSblackmarket.markets[viewing_market].categories
		if(categories && categories.len)
			viewing_category = categories[1]

/obj/item/blackmarket_uplink/attackby(obj/item/I, mob/user, params)
	if(istype(I, /obj/item/holochip) || istype(I, /obj/item/spacecash/bundle) || istype(I, /obj/item/coin))
		var/worth = I.get_item_credit_value()
		if(!worth)
			to_chat(user, span_warning("[I] doesn't seem to be worth anything!"))
		money += worth
		to_chat(user, span_notice("You slot [I] into [src] and it reports a total of [money] credits inserted."))
		qdel(I)
		return
	. = ..()

/obj/item/blackmarket_uplink/AltClick(mob/user)
	if(!isliving(user) || !user.canUseTopic(src, BE_CLOSE, FALSE, NO_TK))
		return

	var/amount_to_remove =  FLOOR(input(user, "How much do you want to withdraw? Current Amount: [money]", "Withdraw Funds", 5) as num|null, 1)
	if(!user.canUseTopic(src, BE_CLOSE, FALSE, NO_TK))
		return

	if(!amount_to_remove || amount_to_remove < 0)
		return
	if(amount_to_remove > money)
		to_chat(user, span_warning("There is only [money] credits in [src]"))
		return

	var/obj/item/holochip/holochip = new (user.drop_location(), amount_to_remove)
	money -= amount_to_remove
	holochip.name = "washed " + holochip.name
	user.put_in_hands(holochip)
	to_chat(user, span_notice("You withdraw [amount_to_remove] credits into a holochip."))

/obj/item/blackmarket_uplink/examine(mob/user)
	. = ..()
	. += span_notice("It's LTSRBT link [target ? "contains a [target]." : "is empty."]")

/obj/item/blackmarket_uplink/ui_interact(mob/user, datum/tgui/ui)
	ui = SStgui.try_update_ui(user, src, ui)
	if(!ui)
		ui = new(user, src, "BlackMarketUplink", name)
		ui.open()

/obj/item/blackmarket_uplink/ui_data(mob/user)
	var/list/data = list()
	var/datum/blackmarket_market/market = viewing_market ? SSblackmarket.markets[viewing_market] : null
	data["categories"] = market ? market.categories : null
	data["delivery_methods"] = list()
	if(market)
		for(var/delivery in market.shipping)
			data["delivery_methods"] += list(list("name" = delivery, "cost" = market.shipping[delivery]))
	data["money"] = money
	data["buying"] = buying
	data["items"] = list()
	data["viewing_category"] = viewing_category
	data["viewing_market"] = viewing_market
	if(viewing_category && market)
		if(market.available_items[viewing_category])
			for(var/datum/blackmarket_item/I in market.available_items[viewing_category])
				if(I.available)
					data["items"] += list(list(
						"id" = I.type,
						"name" = I.name,
						"cost" = I.cost,
						"amount" = I.stock == INFINITY ? "INF" : I.stock,
						"desc" = I.desc || I.name
					))
	return data

/obj/item/blackmarket_uplink/ui_static_data(mob/user)
	var/list/data = list()
	data["delivery_method_description"] = SSblackmarket.shipping_method_descriptions
	data["ltsrbt_built"] = target
	data["markets"] = list()
	for(var/M in accessible_markets)
		var/datum/blackmarket_market/BM = SSblackmarket.markets[M]
		data["markets"] += list(list(
			"id" = M,
			"name" = BM.name
		))
	return data

/obj/item/blackmarket_uplink/ui_act(action, params)
	. = ..()
	if(.)
		return
	switch(action)
		if("set_category")
			if(isnull(params["category"]))
				return
			if(isnull(viewing_market))
				return
			if(!(params["category"] in SSblackmarket.markets[viewing_market].categories))
				return
			viewing_category = params["category"]
			. = TRUE
		if("set_market")
			if(isnull(params["market"]))
				return
			var/market = text2path(params["market"])
			if(!(market in accessible_markets))
				return

			viewing_market = market

			var/list/categories = SSblackmarket.markets[viewing_market].categories
			if(categories && categories.len)
				viewing_category = categories[1]
			else
				viewing_category = null
			. = TRUE
		if("select")
			if(isnull(params["item"]))
				return
			var/item = text2path(params["item"])
			selected_item = item
			buying = TRUE
			. = TRUE
		if("cancel")
			selected_item = null
			buying = FALSE
			. = TRUE
		if("buy")
			if(isnull(params["method"]))
				return
			if(isnull(selected_item))
				buying = FALSE
				return
			var/datum/blackmarket_market/market = SSblackmarket.markets[viewing_market]
			market.purchase(selected_item, viewing_category, params["method"], src, usr)

			buying = FALSE
			selected_item = null

/datum/crafting_recipe/blackmarket_uplink
	name = "Black Market Uplink"
	result = /obj/item/blackmarket_uplink
	time = 30
	tools = list(TOOL_SCREWDRIVER, TOOL_WIRECUTTER, TOOL_MULTITOOL)
	blacklist = list(/obj/item/radio/headset, /obj/item/radio/intercom)
	reqs = list(
		/obj/item/stock_parts/scanning_module = 1,
		/obj/item/stack/cable_coil = 15,
		/obj/item/radio = 1,
		/obj/item/analyzer = 1
	)
	category = CAT_MISC
