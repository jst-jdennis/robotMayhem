extends Node
## The Parts Catalog.
##
## Every robot is made from four slots: a HEAD, a BODY, LEGS and a WEAPON.
## Each part changes the robot's stats a little bit.
##
## Want to add a new part? Copy one of the lines below, give it a new name,
## and change the numbers and colour. That's it! It will show up in the builder.
##
## Stat meanings:
##   hp     - health points. When it reaches 0 the robot is knocked out.
##   speed  - how fast the robot runs (pixels per second).
##   jump   - how high the robot jumps (bigger number = higher).
##   damage - how much health one hit takes away.
##   reach  - how far in front of the robot a hit lands.
##   cooldown - seconds you must wait between swings.

const SLOTS := ["head", "body", "legs", "weapon"]

const HEADS := [
	{"name": "Dome",    "shape": "dome",    "color": Color("#ffcc00"), "hp": 20, "speed": 0,   "jump": 0,  "damage": 0},
	{"name": "Antenna", "shape": "antenna", "color": Color("#7dff7d"), "hp": 0,  "speed": 60,  "jump": 0,  "damage": 0},
	{"name": "Visor",   "shape": "visor",   "color": Color("#ff5e5e"), "hp": 0,  "speed": 0,   "jump": 0,  "damage": 4},
	{"name": "Bucket",  "shape": "bucket",  "color": Color("#9aa5b1"), "hp": 40, "speed": -30, "jump": 0,  "damage": 0},
]

const BODIES := [
	{"name": "Box",    "shape": "box",    "color": Color("#5ac8fa"), "hp": 100, "speed": 0,   "jump": 0,   "damage": 0},
	{"name": "Barrel", "shape": "barrel", "color": Color("#ff9f43"), "hp": 140, "speed": -40, "jump": 0,   "damage": 0},
	{"name": "Slim",   "shape": "slim",   "color": Color("#c56cf0"), "hp": 70,  "speed": 80,  "jump": 60,  "damage": 0},
	{"name": "Tank",   "shape": "tank",   "color": Color("#2ecc71"), "hp": 180, "speed": -80, "jump": -60, "damage": 0},
]

const LEGS := [
	{"name": "Boots",   "shape": "boots",   "color": Color("#8d6e63"), "hp": 0,  "speed": 0,    "jump": 0,    "damage": 0},
	{"name": "Wheels",  "shape": "wheels",  "color": Color("#333333"), "hp": 0,  "speed": 140,  "jump": -120, "damage": 0},
	{"name": "Springs", "shape": "springs", "color": Color("#f1c40f"), "hp": 0,  "speed": -20,  "jump": 220,  "damage": 0},
	{"name": "Treads",  "shape": "treads",  "color": Color("#556b2f"), "hp": 50, "speed": -60,  "jump": -60,  "damage": 0},
]

const WEAPONS := [
	{"name": "Gloves", "shape": "gloves", "color": Color("#e74c3c"), "damage": 8,  "reach": 40, "cooldown": 0.35, "knockback": 250},
	{"name": "Sword",  "shape": "sword",  "color": Color("#bdc3c7"), "damage": 12, "reach": 70, "cooldown": 0.5,  "knockback": 300},
	{"name": "Hammer", "shape": "hammer", "color": Color("#7f8c8d"), "damage": 22, "reach": 60, "cooldown": 1.0,  "knockback": 550},
	{"name": "Claw",   "shape": "claw",   "color": Color("#f39c12"), "damage": 10, "reach": 55, "cooldown": 0.4,  "knockback": 200},
]

## Base stats before any parts are added.
const BASE_HP := 40
const BASE_SPEED := 260.0
const BASE_JUMP := 620.0


func list_for(slot: String) -> Array:
	match slot:
		"head": return HEADS
		"body": return BODIES
		"legs": return LEGS
		"weapon": return WEAPONS
	return []


func part(slot: String, index: int) -> Dictionary:
	var options := list_for(slot)
	if options.is_empty():
		return {}
	return options[posmod(index, options.size())]


## Adds up all the stats of a robot config (a Dictionary of slot -> index).
func stats_for(config: Dictionary) -> Dictionary:
	var total := {
		"hp": BASE_HP,
		"speed": BASE_SPEED,
		"jump": BASE_JUMP,
		"damage": 0,
		"reach": 40,
		"cooldown": 0.5,
		"knockback": 250,
	}
	for slot in SLOTS:
		var p := part(slot, config.get(slot, 0))
		total.hp += p.get("hp", 0)
		total.speed += p.get("speed", 0)
		total.jump += p.get("jump", 0)
		total.damage += p.get("damage", 0)
		if slot == "weapon":
			total.reach = p.get("reach", 40)
			total.cooldown = p.get("cooldown", 0.5)
			total.knockback = p.get("knockback", 250)
	# Never let a robot be slower or weaker than these minimums.
	total.hp = maxi(total.hp, 30)
	total.speed = maxf(total.speed, 120.0)
	total.jump = maxf(total.jump, 400.0)
	total.damage = maxi(total.damage, 1)
	return total


func describe(config: Dictionary) -> String:
	var names: Array[String] = []
	for slot in SLOTS:
		names.append(part(slot, config.get(slot, 0)).get("name", "?"))
	return " + ".join(names)
