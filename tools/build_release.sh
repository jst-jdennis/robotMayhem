#!/usr/bin/env bash
# Makes the two files in release/ that game websites (like Poki) ask for:
#   release/robot-mayhem-web.zip       - the game, playable in a web browser
#   release/robot-mayhem-gameplay.mp4  - a 2-minute video of the game playing itself
#
# Needs: Godot 4.3 with its export templates installed (Editor > Manage
# Export Templates), plus ffmpeg for the video. On Linux without a screen,
# install xvfb too. Run it from the project folder:
#   GODOT=/path/to/godot tools/build_release.sh
set -euo pipefail
cd "$(dirname "$0")/.."
GODOT="${GODOT:-godot}"
mkdir -p build/web release

echo "== Making the web build"
"$GODOT" --headless --path . --export-release "Web" build/web/index.html
rm -f release/robot-mayhem-web.zip
(cd build/web && zip -q -r ../../release/robot-mayhem-web.zip .)

echo "== Filming the demo (this takes a few minutes)"
RUN=()
if [ -z "${DISPLAY:-}" ] && command -v xvfb-run >/dev/null; then
  RUN=(xvfb-run -a -s "-screen 0 1280x720x24")
fi
"${RUN[@]}" "$GODOT" --path . --write-movie build/demo.avi --fixed-fps 30 res://tools/demo_video.tscn
ffmpeg -loglevel error -y -i build/demo.avi -c:v libx264 -preset slow -crf 23 \
  -pix_fmt yuv420p -c:a aac -b:a 128k -movflags +faststart release/robot-mayhem-gameplay.mp4
rm -f build/demo.avi

echo "== Done! Look in the release/ folder."
