# Robot Mayhem 🤖💥

Build a robot out of simple parts, then battle a friend with it!

A two-player fighting game made by a parent and an 8-year-old.
Built with [Godot 4](https://godotengine.org), which is free and can ship to
PC, Nintendo Switch and PlayStation.

## Play it right now (PC)

1. Download **Godot 4.3** from https://godotengine.org/download (pick the
   *standard* version, not .NET). It's a single file, no installer.
2. Open Godot, click **Import**, and choose the `project.godot` file in this folder.
3. Press the **▶ Play** button at the top right (or hit F5).

That's it. No other downloads needed. All the robot art is drawn by code, so
there are no image files to install.

## How to play

**Title screen** – press Space, Enter, or the A button.

**Builder** – Player 1 builds first, then Player 2.

| Action | Keyboard (P1) | Keyboard (P2) | Gamepad |
|---|---|---|---|
| Pick a slot (head / body / legs / weapon) | W / S | Up / Down | D-pad or stick up/down |
| Change the part | A / D | Left / Right | D-pad or stick left/right |
| Done building | Space | Enter | A button |

**Arena** – first to win 3 rounds wins the match.

| Action | Keyboard (P1) | Keyboard (P2) | Gamepad |
|---|---|---|---|
| Run | A / D | Left / Right | Left stick or D-pad |
| Jump | Space | Enter | A button |
| Swing weapon | F | Right Shift | X button |
| Next round | Space or Enter | Space or Enter | A or Start |

Gamepad 1 controls Player 1 and gamepad 2 controls Player 2. You can also share
one keyboard.

## The parts

Every part changes your robot a bit. Mix and match to find your favourite!

| Slot | Parts |
|---|---|
| Head | Dome (extra health), Antenna (faster), Visor (hits harder), Bucket (lots of health, slower) |
| Body | Box (balanced), Barrel (tough, slower), Slim (fast and jumpy, fragile), Tank (super tough, very slow) |
| Legs | Boots (balanced), Wheels (very fast, low jump), Springs (huge jump), Treads (tough, slow) |
| Weapon | Gloves (quick, light), Sword (long reach), Hammer (slow, huge hits), Claw (quick, medium) |

Want to invent a new part? Open `scripts/parts.gd`, copy one of the lines,
and change its name, numbers and colour. It appears in the builder automatically.
To give it its own look, add a drawing for its shape in `scripts/robot_art.gd`.

## Project layout

```
project.godot        Godot project settings and controls
scenes/              One tiny scene file per screen
scripts/
  parts.gd           THE PARTS CATALOG - edit this to add or tweak parts
  robot_art.gd       Draws a robot from its parts using shapes
  robot.gd           Running, jumping, swinging, taking hits
  title.gd           Title screen
  builder.gd         Robot builder screen
  arena.gd           The fight, health bars and round wins
  arena_backdrop.gd  Paints the arena: sunset sky, city, floor
  game_state.gd      Remembers both players' robots and the score
  music.gd           Chiptune music made from maths (no sound files)
tests/smoke_test.*   Automatic test that builds robots and plays a fake round
docs/                Design notes and the console plan
```

## Running the tests

```
godot --headless --path . res://tests/smoke_test.tscn --quit-after 600
```

Prints `ALL TESTS PASSED` when everything works. GitHub runs this on every push.

## Getting onto Switch and PlayStation

See [docs/CONSOLES.md](docs/CONSOLES.md). Short version: the game code stays
the same; the console builds are done through Nintendo and Sony developer
programs plus a Godot console porting partner.
