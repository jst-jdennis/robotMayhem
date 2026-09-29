class_name ArenaBackdrop
extends Node2D
## Paints the arena background: a sunset sky, a big stripy sun, twinkling
## stars, two rows of city buildings with glowing windows, floating clouds,
## and a metal floor with yellow-and-black warning stripes.
## Everything is drawn with shapes, just like the robots.

const W := 1280.0
const H := 720.0

## Where the ground starts, and where the jumping platforms sit.
## The arena sets these before adding us.
var floor_y := 620.0
var platform_xs: Array = []
var platform_y := 450.0

var time := 0.0
var stars: Array = []     # each star: {pos, size, speed}
var far_city: Array = []  # far away buildings (pale purple)
var near_city: Array = [] # close buildings (dark, with windows)
var clouds: Array = []    # each cloud: {x, y, size, speed}


func _ready() -> void:
	# A fixed seed means the city looks the same every fight.
	var rng := RandomNumberGenerator.new()
	rng.seed = 42

	for i in range(70):
		stars.append({
			"pos": Vector2(rng.randf_range(0, W), rng.randf_range(0, 300)),
			"size": rng.randf_range(1.0, 2.5),
			"speed": rng.randf_range(1.0, 3.0),
		})

	var x := -30.0
	while x < W:
		var w := rng.randf_range(60, 120)
		far_city.append(Rect2(x, floor_y - rng.randf_range(160, 380), w, 400))
		x += w - 10

	x = -20.0
	while x < W:
		var w := rng.randf_range(70, 110)
		var h := rng.randf_range(90, 300)
		# Pick which windows have their lights on.
		var lights := []
		for i in range(40):
			lights.append(rng.randf() < 0.45)
		near_city.append({
			"rect": Rect2(x, floor_y - h, w, h),
			"lights": lights,
			"antenna": rng.randf() < 0.4,
		})
		x += w + rng.randf_range(10, 40)

	for i in range(4):
		clouds.append({
			"x": rng.randf_range(0, W),
			"y": rng.randf_range(50, 200),
			"size": rng.randf_range(0.7, 1.3),
			"speed": rng.randf_range(8, 20),
		})


func _process(delta: float) -> void:
	time += delta
	queue_redraw()  # redraw every frame so stars twinkle and clouds move


func _draw() -> void:
	_draw_sky()
	_draw_stars()
	_draw_sun()
	_draw_clouds()
	_draw_far_city()
	_draw_near_city()
	_draw_floor()
	for px in platform_xs:
		_draw_platform(px)


func _draw_sky() -> void:
	# Four corners, each with its own colour: Godot blends them together.
	var top := Color("#140c2e")
	var horizon := Color("#e2587a")
	draw_polygon(
		PackedVector2Array([Vector2(0, 0), Vector2(W, 0), Vector2(W, floor_y), Vector2(0, floor_y)]),
		PackedColorArray([top, top, horizon, horizon]))


func _draw_stars() -> void:
	for s in stars:
		# Each star slowly fades in and out at its own speed.
		var glow := 0.5 + 0.5 * sin(time * s.speed + s.pos.x)
		draw_circle(s.pos, s.size, Color(1, 1, 1, 0.3 + 0.6 * glow))


func _draw_sun() -> void:
	# The sun is built from thin slices, yellow at the top and pink at the
	# bottom. Some slices near the bottom are skipped to make cool stripes.
	var center := Vector2(930, 360)
	var r := 140.0
	var y := -r
	while y < r:
		var band := 4.0
		var t := (y + r) / (2 * r)  # 0 at the top, 1 at the bottom
		var gap := t > 0.45 and int(y + r) % 20 < int(4 + (t - 0.45) * 20)
		if not gap:
			var half := sqrt(max(r * r - y * y, 0.0))
			var col := Color("#ffe066").lerp(Color("#ff4f8b"), t)
			draw_rect(Rect2(center.x - half, center.y + y, half * 2, band), col)
		y += band


func _draw_clouds() -> void:
	for c in clouds:
		var span := W + 300
		var cx: float = fmod(c.x + time * c.speed, span) - 150
		var s: float = c.size
		var col := Color(1, 0.8, 0.9, 0.25)
		draw_circle(Vector2(cx, c.y), 30 * s, col)
		draw_circle(Vector2(cx + 35 * s, c.y - 12 * s), 38 * s, col)
		draw_circle(Vector2(cx + 75 * s, c.y), 28 * s, col)


func _draw_far_city() -> void:
	for b in far_city:
		draw_rect(b, Color("#5a2f6e"))


func _draw_near_city() -> void:
	var body := Color("#1b1433")
	var lit := Color("#ffd35c")
	var dark := Color("#2c2450")
	for b in near_city:
		var rect: Rect2 = b.rect
		draw_rect(rect, body)
		# Windows in neat rows and columns.
		var cols := int((rect.size.x - 12) / 18)
		var rows := int((rect.size.y - 20) / 24)
		var i := 0
		for row in range(rows):
			for col in range(cols):
				var on: bool = b.lights[i % b.lights.size()]
				var pos := rect.position + Vector2(10 + col * 18, 14 + row * 24)
				draw_rect(Rect2(pos, Vector2(9, 12)), lit if on else dark)
				i += 1
		# Some buildings have an antenna with a blinking red light on top.
		if b.antenna:
			var top := Vector2(rect.position.x + rect.size.x / 2, rect.position.y)
			draw_line(top, top - Vector2(0, 30), body, 3)
			var blink := int(time * 2 + rect.position.x) % 2 == 0
			draw_circle(top - Vector2(0, 32), 4, Color("#ff3344") if blink else Color("#551122"))


func _draw_floor() -> void:
	var floor_h := H - floor_y
	draw_rect(Rect2(0, floor_y, W, floor_h), Color("#3d4a5c"))
	# Metal plates with little bolts in the corners.
	var plate := 128.0
	for i in range(int(W / plate) + 1):
		var x := i * plate
		draw_line(Vector2(x, floor_y), Vector2(x, H), Color("#2a3444"), 3)
		for bolt in [Vector2(x + 12, floor_y + 30), Vector2(x + plate - 12, floor_y + 30),
				Vector2(x + 12, H - 14), Vector2(x + plate - 12, H - 14)]:
			draw_circle(bolt, 4, Color("#7f8ea3"))
	_draw_hazard_stripes(Rect2(0, floor_y, W, 14))


func _draw_platform(px: float) -> void:
	var rect := Rect2(px - 110, platform_y, 220, 20)
	# A soft shadow underneath, then the striped platform itself.
	draw_rect(Rect2(rect.position + Vector2(6, 20), Vector2(rect.size.x - 12, 6)), Color(0, 0, 0, 0.3))
	_draw_hazard_stripes(rect)
	draw_rect(rect, Color("#1b1433"), false, 2)


## Yellow and black slanted stripes, like on real warning signs.
func _draw_hazard_stripes(rect: Rect2) -> void:
	draw_rect(rect, Color("#ffcc00"))
	var step := 24.0
	var slant := rect.size.y
	# Only draw stripes that fit completely inside the rectangle.
	var x := rect.position.x + 4
	while x + slant + step / 2 <= rect.end.x:
		draw_colored_polygon(PackedVector2Array([
			Vector2(x, rect.end.y), Vector2(x + slant, rect.position.y),
			Vector2(x + slant + step / 2, rect.position.y), Vector2(x + step / 2, rect.end.y)]),
			Color("#1b1b1b"))
		x += step
