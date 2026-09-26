# Robot Mayhem – notes for AI assistants

A Godot 4.3 two-player robot-building fighting game made by a parent and an
8-year-old. Keep everything simple, readable and kid-friendly.

## Rules of the road

- GDScript only, no addons, no C#. All art is drawn in code (`robot_art.gd`);
  do not add image assets unless asked.
- Every input must have a gamepad binding as well as keyboard (console-ready).
- New parts go in `scripts/parts.gd` (stats) and `scripts/robot_art.gd` (shape).
- Comments should be understandable by a curious 8-year-old.
- Run the smoke test before pushing:
  `godot --headless --path . res://tests/smoke_test.tscn --quit-after 600`
  It must print `ALL TESTS PASSED`.
- Godot's `.godot/` cache is ignored by git; never commit it.

## Layout

See README.md "Project layout". One scene + one script per screen; UI is
built in `_ready()` rather than in `.tscn` files.
