extends Node2D
class_name RobotArt
## Draws a robot out of simple shapes based on its parts.
## No image files needed! Everything is rectangles, circles and lines.
##
## The robot is drawn standing on the point (0, 0), facing to the right.

var config: Dictionary = {"head": 0, "body": 0, "legs": 0, "weapon": 0}
var tint: Color = Color.WHITE
var facing := 1            # 1 = right, -1 = left
var swing := 0.0           # 0..1 while the weapon is swinging
var flash := 0.0           # 0..1 while flashing white after being hit

const BODY_W := 56.0
const BODY_H := 56.0
const LEG_H := 26.0


func set_config(c: Dictionary) -> void:
	config = c.duplicate()
	queue_redraw()


func _process(_delta: float) -> void:
	queue_redraw()


func _draw() -> void:
	var head := Parts.part("head", config.get("head", 0))
	var body := Parts.part("body", config.get("body", 0))
	var legs := Parts.part("legs", config.get("legs", 0))
	var weapon := Parts.part("weapon", config.get("weapon", 0))

	var body_top := -LEG_H - BODY_H
	_draw_legs(legs, body_top)
	_draw_body(body, body_top)
	_draw_head(head, body_top)
	_draw_weapon(weapon, body_top)

	if flash > 0.0:
		draw_rect(Rect2(-40, body_top - 40, 80, 40 + BODY_H + LEG_H), Color(1, 1, 1, flash * 0.6))


func _c(base: Color) -> Color:
	# Mix the part colour with the player's colour just a little so
	# you can always tell whose robot is whose.
	return base.lerp(tint, 0.25)


func _draw_legs(legs: Dictionary, body_top: float) -> void:
	var col := _c(legs.color)
	match legs.shape:
		"wheels":
			draw_circle(Vector2(-16, -12), 12, col)
			draw_circle(Vector2(16, -12), 12, col)
			draw_circle(Vector2(-16, -12), 5, Color.WHITE)
			draw_circle(Vector2(16, -12), 5, Color.WHITE)
		"springs":
			for i in range(3):
				var y := -LEG_H + i * 8
				draw_line(Vector2(-22, y), Vector2(-10, y + 4), col, 4)
				draw_line(Vector2(10, y), Vector2(22, y + 4), col, 4)
			draw_rect(Rect2(-24, -6, 16, 6), col)
			draw_rect(Rect2(8, -6, 16, 6), col)
		"treads":
			draw_rect(Rect2(-32, -22, 64, 22), col)
			for i in range(6):
				draw_rect(Rect2(-30 + i * 10.5, -20, 6, 18), col.darkened(0.3))
		_:
			draw_rect(Rect2(-22, -LEG_H, 14, LEG_H), col)
			draw_rect(Rect2(8, -LEG_H, 14, LEG_H), col)
			draw_rect(Rect2(-26, -6, 20, 6), col.darkened(0.3))
			draw_rect(Rect2(6, -6, 20, 6), col.darkened(0.3))


func _draw_body(body: Dictionary, body_top: float) -> void:
	var col := _c(body.color)
	match body.shape:
		"barrel":
			draw_rect(Rect2(-32, body_top, 64, BODY_H), col)
			draw_rect(Rect2(-32, body_top + 12, 64, 4), col.darkened(0.3))
			draw_rect(Rect2(-32, body_top + 40, 64, 4), col.darkened(0.3))
		"slim":
			draw_rect(Rect2(-18, body_top, 36, BODY_H), col)
			draw_rect(Rect2(-10, body_top + 10, 20, 12), col.lightened(0.4))
		"tank":
			draw_rect(Rect2(-36, body_top + 6, 72, BODY_H - 6), col)
			draw_rect(Rect2(-36, body_top + 6, 72, 8), col.darkened(0.3))
			draw_rect(Rect2(-24, body_top + 24, 12, 12), col.darkened(0.4))
			draw_rect(Rect2(12, body_top + 24, 12, 12), col.darkened(0.4))
		_:
			draw_rect(Rect2(-28, body_top, 56, BODY_H), col)
			draw_rect(Rect2(-16, body_top + 16, 32, 20), col.darkened(0.25))
	# Player-coloured badge so you always know which robot is yours.
	draw_circle(Vector2(0, body_top + BODY_H - 10), 6, tint)


func _draw_head(head: Dictionary, body_top: float) -> void:
	var col := _c(head.color)
	var eye := Color("#1e2233")
	var top := body_top - 26
	match head.shape:
		"dome":
			draw_circle(Vector2(0, body_top), 24, col)
			draw_rect(Rect2(-24, body_top, 48, 4), col.darkened(0.3))
		"antenna":
			draw_rect(Rect2(-16, top + 4, 32, 22), col)
			draw_line(Vector2(0, top + 4), Vector2(0, top - 14), col.darkened(0.3), 3)
			draw_circle(Vector2(0, top - 16), 5, Color("#ff5e5e"))
		"visor":
			draw_rect(Rect2(-20, top + 2, 40, 24), col)
			draw_rect(Rect2(-18, top + 8, 36, 8), Color("#00e5ff"))
			return
		"bucket":
			draw_rect(Rect2(-22, top - 4, 44, 30), col)
			draw_rect(Rect2(-26, top - 8, 52, 6), col.darkened(0.3))
		_:
			draw_rect(Rect2(-18, top + 2, 36, 24), col)
	# Eyes (looking in the direction we face).
	var ex := 6.0 * facing
	draw_circle(Vector2(-8 + ex, top + 12), 4, eye)
	draw_circle(Vector2(8 + ex, top + 12), 4, eye)


func _draw_weapon(weapon: Dictionary, body_top: float) -> void:
	var col := _c(weapon.color)
	var shoulder := Vector2(26 * facing, body_top + 14)
	# Swing the arm forward while attacking: angle goes from -70deg up to +30deg down.
	var angle := lerpf(-1.2, 0.5, swing) * facing
	var length := 34.0
	var tip := shoulder + Vector2(cos(angle), sin(angle)) * length
	# Back arm (the non-weapon one) hangs down.
	draw_line(Vector2(-26 * facing, body_top + 14), Vector2(-30 * facing, body_top + 44), col.darkened(0.4), 8)
	# Weapon arm.
	draw_line(shoulder, tip, col.darkened(0.2), 8)
	var dir := (tip - shoulder).normalized()
	match weapon.shape:
		"sword":
			draw_line(tip, tip + dir * 44, col, 6)
			draw_line(tip - dir.orthogonal() * 8, tip + dir.orthogonal() * 8, col.darkened(0.4), 4)
		"hammer":
			draw_line(tip, tip + dir * 20, col.darkened(0.3), 6)
			var head_center := tip + dir * 26
			draw_rect(Rect2(head_center - Vector2(14, 14), Vector2(28, 28)), col)
		"claw":
			draw_line(tip, tip + dir * 18 + dir.orthogonal() * 12, col, 5)
			draw_line(tip, tip + dir * 18 - dir.orthogonal() * 12, col, 5)
			draw_line(tip, tip + dir * 22, col, 5)
		_:
			draw_circle(tip + dir * 6, 12, col)
