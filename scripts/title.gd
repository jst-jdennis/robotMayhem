extends Control
## The first screen you see. Press Space / Enter / A to start building.

var art1: RobotArt
var art2: RobotArt
var time := 0.0


func _ready() -> void:
	Music.play("menu")
	var bg := ColorRect.new()
	bg.color = Color("#1e2233")
	bg.set_anchors_preset(Control.PRESET_FULL_RECT)
	add_child(bg)

	var title := Label.new()
	title.text = "ROBOT MAYHEM"
	title.add_theme_font_size_override("font_size", 96)
	title.add_theme_color_override("font_color", Color("#ffcc00"))
	title.set_anchors_preset(Control.PRESET_CENTER_TOP)
	title.position = Vector2(0, 90)
	title.anchor_left = 0.5
	title.anchor_right = 0.5
	title.grow_horizontal = Control.GROW_DIRECTION_BOTH
	add_child(title)

	var sub := Label.new()
	sub.text = "Build a robot. Fight your friend. Have fun!"
	sub.add_theme_font_size_override("font_size", 32)
	sub.anchor_left = 0.5
	sub.anchor_right = 0.5
	sub.position = Vector2(0, 210)
	sub.grow_horizontal = Control.GROW_DIRECTION_BOTH
	add_child(sub)

	var prompt := Label.new()
	prompt.name = "Prompt"
	prompt.text = "Press SPACE, ENTER or the A button to start"
	prompt.add_theme_font_size_override("font_size", 28)
	prompt.anchor_left = 0.5
	prompt.anchor_right = 0.5
	prompt.position = Vector2(0, 600)
	prompt.grow_horizontal = Control.GROW_DIRECTION_BOTH
	add_child(prompt)

	var music_hint := Label.new()
	music_hint.text = "Music on/off: M key or the SELECT button"
	music_hint.add_theme_font_size_override("font_size", 20)
	music_hint.add_theme_color_override("font_color", Color("#aab4c0"))
	music_hint.anchor_left = 0.5
	music_hint.anchor_right = 0.5
	music_hint.position = Vector2(0, 660)
	music_hint.grow_horizontal = Control.GROW_DIRECTION_BOTH
	add_child(music_hint)

	art1 = RobotArt.new()
	art1.set_config({"head": 0, "body": 0, "legs": 0, "weapon": 2})
	art1.tint = GameState.PLAYER_COLORS[0]
	art1.position = Vector2(420, 480)
	art1.scale = Vector2(2, 2)
	add_child(art1)

	art2 = RobotArt.new()
	art2.set_config({"head": 2, "body": 2, "legs": 1, "weapon": 1})
	art2.tint = GameState.PLAYER_COLORS[1]
	art2.facing = -1
	art2.position = Vector2(860, 480)
	art2.scale = Vector2(2, 2)
	add_child(art2)


func _process(delta: float) -> void:
	time += delta
	# Make the two robots pretend-fight on the title screen.
	art1.swing = maxf(0.0, sin(time * 3.0))
	art2.swing = maxf(0.0, sin(time * 3.0 + PI))
	var prompt := get_node("Prompt") as Label
	prompt.modulate.a = 0.6 + 0.4 * sin(time * 4.0)


func _unhandled_input(event: InputEvent) -> void:
	if event.is_action_pressed("ui_start"):
		GameState.reset_wins()
		GameState.building_player = 0
		GameState.go_to("res://scenes/builder.tscn")
