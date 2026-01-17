///PAPERS///

/obj/item/paper/fluff/ruins/arachnophobia/pacman
	name = "\improper Power Management"
	default_raw_text = "<center><h1>REMINDER:</h1></center> As per the rationing orders, the last bit of our plasma is NOT to be used in the PACMAN unless the solar panels become misaligned and the console is depowered. If that happens, and I'm not ''around'' to fix it, here's how to get it working:</br>1. Put the plasma in the PACMAN and turn it on. Make sure it's secured.</br>2. Make sure the SMES is recieving power, and the input is up.</br>3. The SMES should power the APC. When it has enough, the solar panel console should turn on.<br> 4. Select ''Auto'' on the console and scan for equipment. If it's strangely low, grab a suit and inspect the panels and cables outside.</br></br>If all else fails, just take one of the spare cells I have in storage and punch it into the APC.</br>-Engineer Kipika-Matara"

/obj/item/paper/crumpled/fluff/ruin/space/arachnophobia/cargo
	name = "\improper diary page"
	default_raw_text = "Alright!!! Day one of my new job at Theta Aranae! Super hyped to get off of that stupid Meta. Out here, I can chillax and only need to unload shit when a shuttle shows up! Other crew seems pretty chill too, there's six of us on total. Dr. Cosita is tooootally my type. Hop<br><br>Well, the lights went out so I had to stop writing. Kipika-Matara's our engineer, seems like he's still getting things set up back there. As long as he can turn the lights back ON, we'll be cool. Maybe I'll make recordings instead, if the lights will be annoying..."

///HOLODISKS///

/obj/item/disk/holodisk/ruin/arachnophobia/cargo_one
	name = "Matthew Bruce - Bored!!"
	preset_image_type = /datum/preset_holoimage/arachnophobia_cargo_tech
	preset_record_text = {"
	NAME Matthew Bruce
	DELAY 10
	SAY Right... I think it's recording.
	DELAY 20
	SAY Heard these were easier to make journals in than paper.
	DELAY 40
	SAY Sooo, been some time since I started now.
	DELAY 30
	SAY I thought I'd enjoy the slower pace, but you know what?
	DELAY 40
	SAY I am bored out of my damn mind!
	DELAY 20
	SAY Ninety percent of the day, I have literally nothing to do.
	DELAY 30
	SAY I've organized the shelves by type and weight...
	DELAY 25
	SAY I've inspected every one of my tools...
	DELAY 25
	SAY I've cleaned every speck of dust off of my desk...
	DELAY 20
	SAY God I hate cleaning.
	DELAY 30
	SAY All the other crew are lame as hell, too.
	DELAY 30
	SAY I tried making some moves on Dr. Cosita, but she wants nothing to do with me.
	DELAY 40
	SAY Kipika and Rasha are alright, I guess... Not big party people, neither is the Captain.
	DELAY 40
	SAY Sooo, guess I'll use these recordings to entertain myself.
	DELAY 30
	SAY What a shitty job.
	DELAY 40
	"}

/obj/item/disk/holodisk/ruin/arachnophobia/cargo_two
	name =  "Matthew Bruce - Our Shipments"
	preset_image_type = /datum/preset_holoimage/arachnophobia_cargo_tech
	preset_record_text = {"
	NAME Matthew Bruce
	DELAY 10
	SAY Nothing's been interesting enough to make a holodisk about since my last one...
	DELAY 40
	SAY Hah, well, until today.
	DELAY 30
	SAY So, usually we just get the basics in our routine shipments.
	DELAY 40
	SAY Food, water, medicine, materials, anything we requested last time...
	DELAY 40
	SAY Well, I've been noticing some extra things have been coming for a while.
	DELAY 40
	SAY Stuff I |know| I didn't order.
	DELAY 20
	SAY They're easy to spot--usually in a big purple crate and labelled something like "research materials."
	DELAY 50
	SAY The manifests were super vague, so I never knew what was in 'em.
	DELAY 40
	SAY Well, got curious today, and Neut-Ria was late picking up her package, so I took a peek inside.
	DELAY 50
	SAY You wanna know what was inside?
	DELAY 30
	SAY Plants!
	DELAY 30
	SAY Saplings, seeds, cuttings... Just tons of plants!
	DELAY 40
	SAY Have we really been out here for like, a year, researching PLANTS?!
	DELAY 40
	SAY Can't they do that shit on a planet? What do the bosses even want with some dumb plants?
	DELAY 50
	SAY Well, maybe I'll ask her to grow me some Retukemi...
	DELAY 30
	SAY That, or just help myself to Dr. Cosita's painkillers.
	DELAY 30
	SAY Hehehe!
	SOUND manlaugh2
	DELAY 40
	SAY ...If you're watching this, uh, that was a joke.
	DELAY 50
	"}

/obj/item/disk/holodisk/ruin/arachnophobia/cargo_three
	name =  "Matthew Bruce - Are we forgotten?"
	preset_image_type = /datum/preset_holoimage/arachnophobia_cargo_tech
	preset_record_text = {"
	NAME Matthew Bruce
	DELAY 10
	SAY Hey... It's me again.
	DELAY 30
	SAY So, it's been like... a few years since my last log.
	DELAY 40
	SAY Didn't think I had any more empty ones... Found this one at the bottom of a crate.
	DELAY 50
	SAY Strange, I thought I had so many...
	DELAY 30
	SAY ...Anyway. Things have gotten tougher around here...
	DELAY 40
	SAY We heard a while back that Nanotrasen's battle with the Coalition was heating up, so our deliveries would be delayed.
	DELAY 50
	SAY They've been getting later and later over time... Now they've stopped completely.
	DELAY 50
	SAY Our last shipment was around five months ago.
	DELAY 40
	SAY We've rationed things out, so hopefully it should last a while, but...
	DELAY 40
	SAY Everyone's definitely worried. There's just been an ominous feeling hanging over everyone.
	DELAY 50
	SAY We're holding out for rescue, but we've got no idea when it'll come.
	DELAY 50
	SAY ...if at all.
	DELAY 80
	SAY -What am I saying? We need optimism now more than ever.
	DELAY 40
	SAY So, I'm going to keep watch on the map, ready to greet our next delivery when they get here.
	DELAY 50
	SAY So, well...
	DELAY 40
	SAY I'll see ya when I see ya!
	DELAY 100
	"}

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

/datum/preset_holoimage/arachnophobia_cargo_tech
	species_type = /datum/species/human
	outfit_type = /datum/outfit/arachnophobia_cargo_tech

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
	loot = list(/obj/structure/spider/spiderling,
		/obj/structure/spider/spiderling,
		/obj/structure/spider/spiderling,
		/obj/structure/spider/spiderling,
		/obj/structure/spider/spiderling,
		/obj/structure/spider/spiderling,
		/obj/structure/spider/spiderling,
		/obj/structure/spider/spiderling,
		/obj/structure/spider/spiderling,
		/obj/structure/spider/spiderling) ///NIGHTMARE NIGHTMARE NIGHTMARE NIGHTMARE
	deathmessage = "'s legs curl inward as its final brood of young are released!"

/mob/living/simple_animal/hostile/poison/giant_spider/nurse/midwife/boss/Initialize()
	. = ..()
	transform = transform.Scale(2, 2)
