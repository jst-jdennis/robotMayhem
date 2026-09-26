# Getting Robot Mayhem onto Switch and PlayStation

## The good news

The game is built with Godot, and Godot games run on Nintendo Switch and
PlayStation. **The code we write does not change.** The same scripts, parts
and scenes work on every platform. Console support comes from the engine,
not from the game.

## The honest part

Console makers keep their development kits secret, so console builds of
Godot are not a free download. Getting there takes three steps and the
first two involve paperwork, not code.

### Step 1 – Make a great PC game first

Ship on PC (and itch.io or Steam) first. Every console publisher wants to see
a finished, fun game before they say yes. This is also where all the fun
building happens.

### Step 2 – Register as a developer

- **Nintendo:** apply at https://developer.nintendo.com. You need to be a
  business (an LLC works) and describe the game. Free to apply; dev kits
  cost money once approved.
- **PlayStation:** apply at https://partners.playstation.net. Same idea.

Both accept small indie studios. Approval can take weeks to months.

### Step 3 – Use a Godot console porting partner

Once you have console developer access, a partner gives you the console
version of the Godot engine and export templates:

- **W4 Games (W4 Consoles)** – https://www.w4games.com – made by Godot's own
  founders. Provides Switch, PlayStation and Xbox exports for Godot 4.
- **Pineapple Works** – https://pineapple.works – a porting studio.
- **Lone Wolf Technology** and others are listed at
  https://docs.godotengine.org/en/stable/tutorials/platform/consoles.html

The official Godot page on this is the best thing to read when the time comes:
https://docs.godotengine.org/en/stable/tutorials/platform/consoles.html

## Things to do now so the port is painless later

These are already set up in the project:

- **Gamepad first.** Every action has a gamepad binding. Consoles have no
  keyboard, so we never rely on one.
- **Fixed 1280×720 canvas** that scales cleanly to 1080p and 4K TVs.
- **Compatibility renderer** (OpenGL-style), the most portable choice.
- **No third-party addons** that might not work on consoles.
- **Everything drawn by code** – no huge texture files to worry about.

Things to keep in mind as we add features:

- Keep all text large enough to read from a couch.
- Never require a mouse.
- Save files must go through Godot's `user://` path (works on all consoles).
- Rated for kids means: no online chat, no real-money stuff, cartoon fighting only.
