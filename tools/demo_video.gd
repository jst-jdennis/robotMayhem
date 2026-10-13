extends Node
## The demo director! It plays Robot Mayhem all by itself so Godot can
## film it. It pretends to press buttons, just like a real player would.
##
## Make a video with (see tools/build_release.sh):
##   godot --path . --write-movie demo.avi --fixed-fps 30 res://tools/demo_video.tscn

## Button presses for the title and builder screens: [seconds, button].
## The time counts from when that screen appears.
const MENU_SCRIPT := {
	"Title": [[3.0, "ui_start"]],
	# Player 1 builds a tough robot: Visor head, Barrel body, Gloves.
	"Builder1": [
		[1.0, "p1_right"], [1.6, "p1_right"], [2.2, "p1_down"], [2.8, "p1_right"],
		[3.6, "p1_down"], [4.2, "p1_down"], [4.8, "p1_right"], [5.4, "p1_right"],
		[5.8, "p1_left"], [5.95, "p1_left"], [6.8, "p1_jump"],
	],
	# Player 2 builds a bouncy robot with Springs and a big Hammer.
	"Builder2": [
		[1.0, "p2_down"], [1.6, "p2_down"], [2.2, "p2_right"], [2.8, "p2_right"],
		[3.4, "p2_left"], [4.0, "p2_down"], [4.6, "p2_right"], [5.6, "p2_jump"],
	],
}

## How long to wait after a knockout before pressing START.
const ROUND_END_WAIT := 2.5
## Stop filming this long after someone wins the whole match.
const MATCH_END_WAIT := 3.0
## Never film for longer than this (in seconds), just in case.
const MAX_LENGTH := 180.0

var rng := RandomNumberGenerator.new()
var total_time := 0.0
var screen_time := 0.0
var screen_name := ""
var screen: Node = null
var menu_step := 0
var round_over_time := -1.0
var held := {}          # buttons being held down right now
var tapped: Array = []  # buttons to let go of next frame
var retreat := [0.0, 0.0]  # how long each bot backs away after a hit


func _ready() -> void:
	rng.seed = 2026  # same seed = the same video every time
	# Put the real game next to us, so changing screens doesn't remove us.
	var tree := get_tree()
	(func():
		var game: Node = load(ProjectSettings.get_setting("application/run/main_scene")).instantiate()
		tree.root.add_child(game)
		tree.current_scene = game
	).call_deferred()


func _physics_process(delta: float) -> void:
	total_time += delta
	for action in tapped:
		Input.action_release(action)
	tapped.clear()

	var scene := get_tree().current_scene
	if scene == null or scene == self:
		return
	if scene != screen:  # a new screen just appeared
		screen = scene
		screen_name = scene.name
		screen_time = 0.0
		menu_step = 0
		round_over_time = -1.0
		_let_go_of_everything()
	screen_time += delta

	if screen_name == "Arena":
		_play_arena(scene)
	else:
		_play_menu()

	if total_time > MAX_LENGTH:
		get_tree().quit()


## Press a button for just one frame.
func _tap(action: String) -> void:
	Input.action_press(action)
	# Screens like the builder listen for button "events", so send one too.
	var event := InputEventAction.new()
	event.action = action
	event.pressed = true
	Input.parse_input_event(event)
	tapped.append(action)


## Hold a button down (or let it go). We press it again every frame,
## like a finger that keeps pushing, so Godot never forgets it is held.
func _hold(action: String, down: bool) -> void:
	if down:
		Input.action_press(action)
		held[action] = true
	elif not down and held.has(action):
		Input.action_release(action)
		held.erase(action)


func _let_go_of_everything() -> void:
	for action in held.keys():
		Input.action_release(action)
	held.clear()


func _play_menu() -> void:
	var page := screen_name
	if page == "Builder":
		page += str(GameState.building_player + 1)  # "Builder1" or "Builder2"
	var steps: Array = MENU_SCRIPT.get(page, [])
	if menu_step < steps.size() and screen_time >= steps[menu_step][0]:
		_tap(steps[menu_step][1])
		menu_step += 1


func _play_arena(arena: Node) -> void:
	if arena.round_over:
		_let_go_of_everything()
		if round_over_time < 0.0:
			round_over_time = screen_time
		var match_over: bool = GameState.wins.max() >= arena.WINS_NEEDED
		if match_over and screen_time - round_over_time > MATCH_END_WAIT:
			get_tree().quit()
		elif not match_over and screen_time - round_over_time > ROUND_END_WAIT:
			_tap("ui_start")
		return
	if not arena.fight_started:
		return
	var bots: Array = arena.robots
	for i in range(2):
		_think(bots[i], bots[1 - i], i)


## A simple robot brain: walk up to the other robot and bonk it!
func _think(me: Robot, enemy: Robot, i: int) -> void:
	var p := "p%d_" % (i + 1)
	var dx := enemy.position.x - me.position.x
	var toward := "right" if dx > 0 else "left"
	var away := "left" if dx > 0 else "right"
	var reach: float = me.stats.reach + 30.0
	var go := ""
	var middle := "right" if me.position.x < 640.0 else "left"

	retreat[i] = maxf(retreat[i] - get_physics_process_delta_time(), 0.0)
	if absf(enemy.position.y - me.position.y) > 60.0:
		if absf(dx) < 80.0:
			go = away  # someone is standing on a head! Step apart.
		else:
			# Someone is up on a platform: head for the middle of the arena
			# so the one on top walks off the edge and drops down.
			go = middle
	elif retreat[i] > 0.0:
		go = away
	elif absf(dx) > reach:
		go = toward
	elif signf(dx) != float(me.facing):
		go = toward  # turn around to face the enemy
	elif me.attack_cooldown <= 0.0 and rng.randf() < 0.5:
		_tap(p + "attack")
		# Sometimes jump back after swinging, to make it more exciting.
		if rng.randf() < 0.3:
			retreat[i] = rng.randf_range(0.2, 0.5)

	_hold(p + "left", go == "left")
	_hold(p + "right", go == "right")
	if me.is_on_floor() and rng.randf() < 0.004:
		_tap(p + "jump")
