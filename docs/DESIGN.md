# Robot Mayhem – Design Notes

## The idea in one sentence

You build a robot out of a few simple parts, then fight a friend with it.

## What makes it fun

- **Every part matters.** Pick Springs and you bounce over hammers. Pick Tank
  and you can take a beating but can't chase anyone down.
- **Fast rounds.** A round lasts about 20–40 seconds. First to 3 wins.
- **You can see your choices.** The robot is drawn from its parts, so a Bucket
  head really looks like a bucket.
- **No wrong answers.** Every combination has stats that are at least okay
  (the game enforces minimum health, speed, jump and damage).

## Version 1 (this is what's built)

- 4 slots × 4 parts each = 256 possible robots
- Local 2-player on one PC (keyboard share or two gamepads)
- One arena with a floor and two platforms
- Melee attacks only, knockback, short stun on hit, best-of-5 match

## Ideas for later (pick whichever sounds most fun!)

- [ ] Sound effects and music (clangs, boings, a crowd going "ooooh")
- [ ] More parts: jetpack legs, laser weapon, shield arm, spinning saw
- [ ] Ranged weapons that shoot projectiles
- [ ] More arenas: lava floor, moving platforms, bouncy walls
- [ ] A one-player mode against a computer robot
- [ ] Naming your robot and saving your favourite builds
- [ ] Special move when you press jump + attack
- [ ] Power-ups that drop into the arena mid-fight
- [ ] Pick your robot's paint colour
- [ ] Up to 4 players

## How the code is organised

Each screen is one scene with one script. The scripts build their own
buttons and labels in code, so there is very little to get lost in.

```
Title  ->  Builder (P1)  ->  Builder (P2)  ->  Arena  ->  (repeat rounds)
```

`GameState` is an "autoload", which means it is always there and never
resets when a scene changes. It remembers what both players built and the
score.

`Parts` is also an autoload. It holds the catalog and adds up stats.

`RobotArt` draws a robot with rectangles, circles and lines. Because the art
is code, adding a part only needs a few lines and no drawing program.

## Balance numbers (starting point, tune by playing!)

Base robot: 40 hp, 260 speed, 620 jump. Parts add or subtract from those.
A Hammer does 22 damage; a Gloves robot with Visor does 12. A typical robot
has 140–220 hp, so a fight takes roughly 8–15 landed hits.
