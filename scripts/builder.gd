extends Control
## The Robot Builder.
##
## Player 1 builds first, then Player 2. Use UP/DOWN to pick a slot
## (head, body, legs, weapon), LEFT/RIGHT to change the part, and
## JUMP (Space / Enter / A button) when you're happy with your robot.

var player := 0
var slot_index := 0
var art: RobotArt
var slot_labels: Array[Label] = []
var stat_label: Label
var header: Label
var name_label: Label
var time := 0.0


func _ready() -> void:
	Music.play("menu")
	player = GameState.building_player
	_build_ui()
	_refresh()


func _build_ui() -> void:
	var bg := ColorRect.new()
	bg.color = Color("#1e2233")
	bg.set_anchors_preset(Control.PRESET_FULL_RECT)
	add_child(bg)

	header = Label.new()
	header.add_theme_font_size_override("font_size", 56)
	header.add_theme_color_override("font_color", GameState.PLAYER_COLORS[player])
	header.position = Vector2(60, 40)
	add_child(header)

	var help := Label.new()
	help.text = "UP / DOWN: choose a slot     LEFT / RIGHT: change the part     JUMP button: done!"
	help.add_theme_font_size_override("font_size", 22)
	help.add_theme_color_override("font_color", Color("#aab4c0"))
	help.position = Vector2(60, 110)
	add_child(help)

	for i in Parts.SLOTS.size():
		var l := Label.new()
		l.add_theme_font_size_override("font_size", 40)
		l.position = Vector2(80, 190 + i * 80)
		add_child(l)
		slot_labels.append(l)

	stat_label = Label.new()
	stat_label.add_theme_font_size_override("font_size", 28)
	stat_label.position = Vector2(80, 530)
	add_child(stat_label)

	name_label = Label.new()
	name_label.add_theme_font_size_override("font_size", 26)
	name_label.add_theme_color_override("font_color", Color("#aab4c0"))
	name_label.position = Vector2(700, 600)
	add_child(name_label)

	var stand := ColorRect.new()
	stand.color = Color("#2d3348")
	stand.position = Vector2(760, 500)
	stand.size = Vector2(320, 24)
	add_child(stand)

	art = RobotArt.new()
	art.tint = GameState.PLAYER_COLORS[player]
	art.position = Vector2(920, 500)
	art.scale = Vector2(3, 3)
	add_child(art)


func _refresh() -> void:
	var config: Dictionary = GameState.robots[player]
	header.text = "%s: build your robot!" % GameState.PLAYER_NAMES[player]
	for i in Parts.SLOTS.size():
		var slot: String = Parts.SLOTS[i]
		var p := Parts.part(slot, config[slot])
		var arrow := ">" if i == slot_index else " "
		slot_labels[i].text = "%s %s:  <  %s  >" % [arrow, slot.capitalize(), p.name]
		slot_labels[i].add_theme_color_override("font_color",
			Color("#ffcc00") if i == slot_index else Color.WHITE)
	var s := Parts.stats_for(config)
	stat_label.text = "Health: %d     Speed: %d     Jump: %d\nDamage: %d     Reach: %d     Swing time: %.2fs" % [
		s.hp, int(s.speed), int(s.jump), s.damage, int(s.reach), s.cooldown]
	name_label.text = Parts.describe(config)
	art.set_config(config)


func _process(delta: float) -> void:
	time += delta
	art.facing = 1 if fmod(time, 4.0) < 2.0 else -1
	art.swing = maxf(0.0, sin(time * 2.5))


func _unhandled_input(event: InputEvent) -> void:
	# Both players' controls work in the builder so nobody has to swap seats.
	var config: Dictionary = GameState.robots[player]
	var slot: String = Parts.SLOTS[slot_index]
	var count := Parts.list_for(slot).size()
	if event.is_action_pressed("p1_down") or event.is_action_pressed("p2_down"):
		slot_index = posmod(slot_index + 1, Parts.SLOTS.size())
	elif event.is_action_pressed("p1_up") or event.is_action_pressed("p2_up"):
		slot_index = posmod(slot_index - 1, Parts.SLOTS.size())
	elif event.is_action_pressed("p1_right") or event.is_action_pressed("p2_right"):
		config[slot] = posmod(config[slot] + 1, count)
	elif event.is_action_pressed("p1_left") or event.is_action_pressed("p2_left"):
		config[slot] = posmod(config[slot] - 1, count)
	elif event.is_action_pressed("p1_jump") or event.is_action_pressed("p2_jump") or event.is_action_pressed("ui_start"):
		_done()
		return
	else:
		return
	_refresh()


func _done() -> void:
	if player == 0:
		GameState.building_player = 1
		GameState.go_to("res://scenes/builder.tscn")
	else:
		GameState.building_player = 0
		GameState.go_to("res://scenes/arena.tscn")
