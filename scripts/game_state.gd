extends Node
## Remembers what both players built so the arena can use it.
## This is an "autoload" so every scene can reach it with `GameState`.

const PLAYER_COLORS := [Color("#4fc3f7"), Color("#ff7043")]
const PLAYER_NAMES := ["Player 1", "Player 2"]

## One config per player. Each config is {head, body, legs, weapon} -> part index.
var robots: Array[Dictionary] = [
	{"head": 0, "body": 0, "legs": 0, "weapon": 0},
	{"head": 1, "body": 2, "legs": 1, "weapon": 1},
]

## Round wins for each player.
var wins: Array[int] = [0, 0]

## Which player is currently building (0 or 1).
var building_player := 0


func reset_wins() -> void:
	wins = [0, 0]


func go_to(scene_path: String) -> void:
	get_tree().change_scene_to_file(scene_path)
