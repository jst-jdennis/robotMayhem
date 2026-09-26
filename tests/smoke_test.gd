extends Node
## Headless smoke test. Run with:
##   godot --headless --path . res://tests/smoke_test.tscn
## It checks the parts catalog, builds two robots, runs a fake fight
## and makes sure a winner is declared. Prints "ALL TESTS PASSED" on success.

var failures := 0


func check(cond: bool, what: String) -> void:
	if cond:
		print("  ok   - ", what)
	else:
		failures += 1
		printerr("  FAIL - ", what)


func _ready() -> void:
	var parts := Parts
	var state := GameState
	await get_tree().process_frame

	print("Parts catalog")
	for slot in parts.SLOTS:
		check(parts.list_for(slot).size() >= 2, "slot '%s' has at least two parts" % slot)
	var every_config := []
	for h in parts.HEADS.size():
		for b in parts.BODIES.size():
			for l in parts.LEGS.size():
				for w in parts.WEAPONS.size():
					every_config.append({"head": h, "body": b, "legs": l, "weapon": w})
	var all_sane := true
	for c in every_config:
		var s: Dictionary = parts.stats_for(c)
		if s.hp <= 0 or s.speed <= 0 or s.jump <= 0 or s.damage <= 0 or s.cooldown <= 0:
			all_sane = false
	check(all_sane, "every one of %d robot combinations has positive stats" % every_config.size())
	check(parts.part("head", 99).name == parts.part("head", 99 % parts.HEADS.size()).name, "part index wraps around")

	print("Arena fight")
	var arena_scene: PackedScene = load("res://scenes/arena.tscn")
	var arena = arena_scene.instantiate()
	add_child(arena)
	await get_tree().process_frame
	await get_tree().process_frame
	var robots := get_tree().get_nodes_in_group("robots")
	check(robots.size() == 2, "two robots spawned")
	var p1 = robots[0]
	var p2 = robots[1]
	check(p1.hp == parts.stats_for(state.robots[0]).hp, "player 1 starts with full health")

	var winner_declared := [false]
	p2.knocked_out.connect(func(_i): winner_declared[0] = true)
	var hits := 0
	while p2.alive and hits < 100:
		p2.take_hit(25, 100.0)
		hits += 1
	check(winner_declared[0], "player 2 is knocked out after %d hits" % hits)
	await get_tree().process_frame
	check(state.wins[0] == 1, "player 1 is credited with the round win (wins = %s)" % [state.wins])
	check(arena.round_over, "arena knows the round is over")

	print("Robot reach check")
	# Put p1 right next to p2 and swing: p2 should take damage even if already KO'd? No - alive check.
	var arena2 = arena_scene.instantiate()
	arena.queue_free()
	add_child(arena2)
	await get_tree().process_frame
	await get_tree().process_frame
	var r := get_tree().get_nodes_in_group("robots")
	var a = r[0]
	var b = r[1]
	b.position = a.position + Vector2(60, 0)
	a.facing = 1
	var before: int = b.hp
	a._land_hit()
	check(b.hp < before, "a swing within reach takes health from the other robot")
	b.position = a.position + Vector2(600, 0)
	before = b.hp
	a._land_hit()
	check(b.hp == before, "a swing out of reach does nothing")

	if failures == 0:
		print("ALL TESTS PASSED")
		get_tree().quit(0)
	else:
		printerr("%d TEST(S) FAILED" % failures)
		get_tree().quit(1)
