extends Node2D
## The fight! Two robots, one arena, first to 3 round wins takes it.

const ROBOT_SCENE := preload("res://scenes/robot.tscn")
const WINS_NEEDED := 3
const FLOOR_Y := 620.0

var robots: Array[Robot] = []
var hp_bars: Array[ProgressBar] = []
var message: Label
var wins_label: Label
var round_over := false
var countdown := 3.0
var fight_started := false


func _ready() -> void:
	Music.play("fight")
	_build_arena()
	_build_hud()
	_spawn_robots()
	_show_message("Ready...")


func _build_arena() -> void:
	# The painted background: sky, sun, city, floor and platform stripes.
	var backdrop := ArenaBackdrop.new()
	backdrop.floor_y = FLOOR_Y
	backdrop.platform_xs = [200.0, 1080.0]
	backdrop.platform_y = 450.0
	add_child(backdrop)

	var ground := StaticBody2D.new()
	var shape := CollisionShape2D.new()
	var rect := RectangleShape2D.new()
	rect.size = Vector2(1280, 100)
	shape.shape = rect
	shape.position = Vector2(640, FLOOR_Y + 50)
	ground.add_child(shape)
	add_child(ground)

	# Two small platforms to jump on.
	for x in [200.0, 1080.0]:
		var plat := StaticBody2D.new()
		plat.position = Vector2(x, 460)
		var ps := CollisionShape2D.new()
		var pr := RectangleShape2D.new()
		pr.size = Vector2(220, 20)
		ps.shape = pr
		ps.one_way_collision = true
		plat.add_child(ps)
		add_child(plat)


func _build_hud() -> void:
	var hud := CanvasLayer.new()
	add_child(hud)
	for i in range(2):
		var name_l := Label.new()
		name_l.text = GameState.PLAYER_NAMES[i]
		name_l.add_theme_font_size_override("font_size", 28)
		name_l.add_theme_color_override("font_color", GameState.PLAYER_COLORS[i])
		name_l.position = Vector2(40 if i == 0 else 1240 - 200, 20)
		hud.add_child(name_l)

		var bar := ProgressBar.new()
		bar.position = Vector2(40 if i == 0 else 1240 - 440, 60)
		bar.size = Vector2(440, 34)
		bar.show_percentage = false
		var fill := StyleBoxFlat.new()
		fill.bg_color = GameState.PLAYER_COLORS[i]
		bar.add_theme_stylebox_override("fill", fill)
		var back := StyleBoxFlat.new()
		back.bg_color = Color("#101420")
		bar.add_theme_stylebox_override("background", back)
		hud.add_child(bar)
		hp_bars.append(bar)

	wins_label = Label.new()
	wins_label.add_theme_font_size_override("font_size", 30)
	wins_label.anchor_left = 0.5
	wins_label.anchor_right = 0.5
	wins_label.grow_horizontal = Control.GROW_DIRECTION_BOTH
	wins_label.position = Vector2(0, 24)
	hud.add_child(wins_label)
	_refresh_wins()

	message = Label.new()
	message.add_theme_font_size_override("font_size", 80)
	message.add_theme_color_override("font_color", Color("#ffcc00"))
	# A dark outline keeps the words easy to read on the bright sky.
	message.add_theme_color_override("font_outline_color", Color("#1b1433"))
	message.add_theme_constant_override("outline_size", 16)
	message.anchor_left = 0.5
	message.anchor_right = 0.5
	message.grow_horizontal = Control.GROW_DIRECTION_BOTH
	message.position = Vector2(0, 250)
	message.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	hud.add_child(message)


func _spawn_robots() -> void:
	for i in range(2):
		var r: Robot = ROBOT_SCENE.instantiate()
		r.player_index = i
		r.position = Vector2(300 if i == 0 else 980, FLOOR_Y)
		r.controls_enabled = false
		r.add_to_group("robots")
		r.hp_changed.connect(_on_hp_changed.bind(i))
		r.knocked_out.connect(_on_knocked_out)
		add_child(r)
		robots.append(r)


func _on_hp_changed(current: int, maximum: int, i: int) -> void:
	hp_bars[i].max_value = maximum
	hp_bars[i].value = current


func _refresh_wins() -> void:
	wins_label.text = "%d  -  %d" % [GameState.wins[0], GameState.wins[1]]


func _show_message(text: String) -> void:
	message.text = text
	message.visible = text != ""


func _process(delta: float) -> void:
	if not fight_started:
		countdown -= delta
		if countdown > 0.0:
			_show_message(str(ceili(countdown)))
		else:
			fight_started = true
			_show_message("FIGHT!")
			for r in robots:
				r.controls_enabled = true
			get_tree().create_timer(0.8).timeout.connect(func(): if not round_over: _show_message(""))
	elif round_over and Input.is_action_just_pressed("ui_start"):
		_next()


func _on_knocked_out(loser: int) -> void:
	if round_over:
		return
	round_over = true
	var winner := 1 - loser
	GameState.wins[winner] += 1
	_refresh_wins()
	for r in robots:
		r.controls_enabled = false
	if GameState.wins[winner] >= WINS_NEEDED:
		_show_message("%s WINS THE MATCH!\nPress START to build new robots" % GameState.PLAYER_NAMES[winner].to_upper())
	else:
		_show_message("%s wins the round!\nPress START for the next round" % GameState.PLAYER_NAMES[winner])


func _next() -> void:
	if GameState.wins[0] >= WINS_NEEDED or GameState.wins[1] >= WINS_NEEDED:
		GameState.reset_wins()
		GameState.building_player = 0
		GameState.go_to("res://scenes/builder.tscn")
	else:
		GameState.go_to("res://scenes/arena.tscn")
