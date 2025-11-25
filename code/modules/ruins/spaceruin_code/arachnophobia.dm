///PAPERS///

/obj/item/paper/fluff/ruins/arachnophobia/pacman
	name = "\improper Power Management"
	default_raw_text = "<center><h1>REMINDER:</h1></center> As per the rationing orders, the last bit of our plasma is NOT to be used in the PACMAN unless the solar panels become misaligned and the console is depowered. If that happens, and I'm not ''around'' to fix it, here's how to get it working:</br>1. Put the plasma in the PACMAN and turn it on. Make sure it's secured.</br>2. Make sure the SMES is recieving power, and the input is up.</br>3. The SMES should power the APC. When it has enough, the solar panel console should turn on.<br> 4. Select ''Auto'' on the console and scan for equipment. If it's strangely low, grab a suit and inspect the panels and cables outside.</br></br>If all else fails, just take one of the spare cells I have in storage and punch it into the APC.</br>-Engineer Kipika-Matara"

/obj/item/paper/crumpled/fluff/ruin/space/arachnophobia/cargo
	name = "\improper diary page"
	default_raw_text = "Alright!!! Day one of my new job at Theta Aranae! Super hyped to get off of that stupid Meta. Out here, I can chillax and only need to unload shit when a shuttle shows up! Other crew seems pretty chill too, there's six of us on total. Dr. Cosita is tooootally my type. Hop<br><br>Well, the lights went out so I had to stop writing. Kipika-Matara's our engineer, seems like he's still getting things set up back there. As long as he can turn the lights back ON, we'll be cool. Maybe I'll make recordings instead, if the lights will be annoying..."

///HOLODISKS///



///OUTFITS///

/obj/item/card/id/ruin/arachnophobia_cargo
	registered_age = 27
	registered_name = "Matthew Bruce"
	job_icon = "cargotechnician"

/datum/outfit/arachnophobia_cargo_tech
	name = "Arachnophobia - Cargo Tech"
	belt = /obj/item/pda/cargo
	ears = /obj/item/radio/headset/headset_cargo
	head = /obj/item/clothing/head/nanotrasen/cap/supply
	neck = /obj/item/clothing/neck/scarf/yellow
	uniform = /obj/item/clothing/under/nanotrasen/supply
	back = /obj/item/storage/backpack/messenger
	gloves = /obj/item/clothing/gloves/fingerless
	shoes = /obj/item/clothing/shoes/sneakers/black
	glasses = /obj/item/clothing/glasses/cheapsuns
	id = /obj/item/card/id/ruin/arachnophobia_cargo

/obj/effect/mob_spawn/human/corpse/ruin/arachnophobia/cargo_tech
	outfit = /datum/outfit/arachnophobia_cargo_tech
	mob_gender = MALE
	mob_name = "Matthew Bruce"
	id_job = "Cargo Technician"
	hairstyle = "Shaved Part"
	facial_hairstyle = "Shaved"
	skin_tone = "caucasian1"
	brute_damage = 200

///MOBS///

/mob/living/simple_animal/hostile/poison/giant_spider/nurse/midwife/boss
	name = "giant spider queen"
	desc = "A massive, hulking spider mutated far beyond a reasonable size. Its emerald eyes stare hauntingly at you, while shiny beads of venom drip from the tips of its fangs. Looks like you're on the menu tonight."
	icon_state = "midwife"
	icon_living = "midwife"
	icon_dead = "midwife_dead"
	butcher_results = list(/obj/item/food/meat/slab/spider = 4, /obj/item/food/spiderleg = 8, /obj/item/food/spidereggs = 6)
	maxHealth = 200
	health = 200
	melee_damage_lower = 15
	melee_damage_upper = 20
	poison_per_bite = 5 ///11 tox damage per bite
	loot = list(/obj/structure/spider/spiderling, /obj/structure/spider/spiderling, /obj/structure/spider/spiderling, /obj/structure/spider/spiderling, /obj/structure/spider/spiderling, /obj/structure/spider/spiderling, /obj/structure/spider/spiderling, /obj/structure/spider/spiderling, /obj/structure/spider/spiderling, /obj/structure/spider/spiderling) ///NIGHTMARE NIGHTMARE NIGHTMARE NIGHTMARE
	deathmessage = "'s legs curl inward as its final brood of young are released!"

/mob/living/simple_animal/hostile/poison/giant_spider/nurse/midwife/boss/Initialize()
	. = ..()
	transform = transform.Scale(2, 2)
