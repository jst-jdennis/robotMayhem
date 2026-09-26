extends CharacterBody2D
class_name Robot
## A robot that can run, jump and swing its weapon.
## Player 1 and Player 2 both use this same script; only the input names differ.

signal hp_changed(current: int, maximum: int)
signal knocked_out(player_index: int)

@export var player_index := 0

var config: Dictionary
var stats: Dictionary
var hp := 100
var facing := 1
var attack_cooldown := 0.0
var swing_time := 0.0
var hit_flash := 0.0
var stun := 0.0
var alive := true
var controls_enabled := true

const GRAVITY := 1800.0
const SWING_LENGTH := 0.22   # seconds the swing animation takes
const HIT_MOMENT := 0.10     # when during the swing the hit actually lands

var art: RobotArt
var did_hit_this_swing := false


func _ready() -> void:
	config = GameState.robots[player_index]
	stats = Parts.stats_for(config)
	hp = stats.hp
	facing = 1 if player_index == 0 else -1

	art = RobotArt.new()
	art.set_config(config)
	art.tint = GameState.PLAYER_COLORS[player_index]
	add_child(art)

	var shape := CollisionShape2D.new()
	var rect := RectangleShape2D.new()
	rect.size = Vector2(56, 82)
	shape.shape = rect
	shape.position = Vector2(0, -41)
	add_child(shape)

	hp_changed.emit(hp, stats.hp)


func _action(name: String) -> String:
	return "p%d_%s" % [player_index + 1, name]


func _physics_process(delta: float) -> void:
	attack_cooldown = maxf(attack_cooldown - delta, 0.0)
	hit_flash = maxf(hit_flash - delta * 4.0, 0.0)
	stun = maxf(stun - delta, 0.0)

	if not is_on_floor():
		velocity.y += GRAVITY * delta

	var can_control := alive and controls_enabled and stun <= 0.0
	var dir := 0.0
	if can_control:
		dir = Input.get_action_strength(_action("right")) - Input.get_action_strength(_action("left"))
		if Input.is_action_just_pressed(_action("jump")) and is_on_floor():
			velocity.y = -stats.jump
		if Input.is_action_just_pressed(_action("attack")) and attack_cooldown <= 0.0:
			_start_swing()

	if can_control:
		velocity.x = move_toward(velocity.x, dir * stats.speed, 2400.0 * delta)
		if dir != 0.0:
			facing = 1 if dir > 0 else -1
	else:
		velocity.x = move_toward(velocity.x, 0.0, 1200.0 * delta)

	move_and_slide()

	# Keep robots inside the arena.
	var limit := get_viewport_rect().size.x
	position.x = clampf(position.x, 40, limit - 40)

	_update_swing(delta)
	art.facing = facing
	art.flash = hit_flash


func _start_swing() -> void:
	attack_cooldown = stats.cooldown
	swing_time = SWING_LENGTH
	did_hit_this_swing = false


func _update_swing(delta: float) -> void:
	if swing_time > 0.0:
		swing_time -= delta
		var progress := 1.0 - (swing_time / SWING_LENGTH)
		art.swing = progress
		if not did_hit_this_swing and progress >= HIT_MOMENT / SWING_LENGTH:
			did_hit_this_swing = true
			_land_hit()
	else:
		art.swing = 0.0


func _land_hit() -> void:
	# Look for the other robot inside our reach, in front of us.
	var reach: float = stats.reach + 40.0
	for other in get_tree().get_nodes_in_group("robots"):
		if other == self or not other.alive:
			continue
		var dx: float = other.position.x - position.x
		var dy: float = absf(other.position.y - position.y)
		if signf(dx) == float(facing) and absf(dx) <= reach and dy < 70.0:
			other.take_hit(stats.damage, facing * stats.knockback)


func take_hit(damage: int, knockback_x: float) -> void:
	if not alive:
		return
	hp = maxi(hp - damage, 0)
	hit_flash = 1.0
	stun = 0.18
	velocity.x = knockback_x
	velocity.y = -220.0
	hp_changed.emit(hp, stats.hp)
	if hp == 0:
		alive = false
		knocked_out.emit(player_index)
		var tween := create_tween()
		tween.tween_property(art, "rotation", PI / 2 * -facing, 0.5).set_trans(Tween.TRANS_BOUNCE)
