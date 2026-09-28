///machines

/obj/machinery/computer/atmos_control/ship/eagle
	sensors = list(
		"eagle_air" = "Airmix Chamber",
		"eagle_o2" = "Oxygen Chamber",
		"eagle_n2" = "Nitrogen Chamber",
		"eagle_plasma" = "Plasma Chamber",
		"eagle_burn" = "TEG Burn Chamber",
	)

/obj/machinery/air_sensor/ship/eagle/air
	id_tag = "eagle_air"

/obj/machinery/air_sensor/ship/eagle/o2
	id_tag = "eagle_o2"

/obj/machinery/air_sensor/ship/eagle/n2
	id_tag = "eagle_n2"

/obj/machinery/air_sensor/ship/eagle/plasma
	id_tag = "eagle_plasma"

/obj/machinery/air_sensor/ship/eagle/burn
	id_tag = "eagle_burn"

///holodisks

/datum/preset_holoimage/eaglecap
	species_type = /datum/species/human
	outfit_type = /datum/outfit/job/warra/captain/centcom

/obj/item/disk/holodisk/ship/eagle/captain
name = "holorecord disk - Captain's Briefing"
preset_image_type = /datum/preset_holoimage/eaglecap
preset_record_text = {"
NAME Central Officer Selmett Talenkov
Hello, Captain, and congratulations on your command of this Eagle-class Frontier Cruiser!
You stand as the officer in charge of one of Makosso-Warra's largest vessels in the Frontier.
With the tools provided to you as Captain, the value of this vessel lies in your hands to achieve your and the Company's objectives.
Communication and cooperation with the N+S and Vigilitas liasons will be critical in your vessel's success.
Remember, you have an extremely large ship to run. Delegate tasks to crewmembers to lighten your load and let them prove their proficiencies.
While the Supply and Security Directors will have command over their respective areas and personnel...
...remember that you are the supreme authority on the ship, and can override their decisions.
If you have any Assistants aboard, make sure to get them an assignment. Don't forget your command console can create custom positions.
Some common special assignments given to Assistants are, in no exhaustive list:
Security Cadet, Janitor, Cargo Technician, Cook, Helmsman, Paramedic, First Officer...
The list goes on.
Remember, Captain, the onus is on you to make this ship a success. Even the best crew requires a skilled leader to organize them.
Ensure cooperation between all three corporations to gurantee effective operations.
Good luck, Captain. You and the Eagle are the pride of Makosso-Warra's Frontier Recovery Initiative.
May you shine brightly.
"}

/obj/item/disk/holodisk/ship/eagle/secdir
name = "holorecord disk - Security Director's Briefing"

/obj/item/disk/holodisk/ship/eagle/supdir
name = "holorecord disk - Supply Director's Briefing"

/obj/item/disk/holodisk/ship/eagle/engie
name = "holorecord disk - Engineering Briefing"

/obj/item/disk/holodisk/ship/eagle/doctor
name = "holorecord disk - Medical Briefing"
