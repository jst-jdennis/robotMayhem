extends Node
## The game's music box! There are no music files: every sound is made
## from maths, like an old video game console.
##
## Each song is a list of notes. A number is a note (60 is middle C, and
## +12 is the same note one step higher), and 0 means "be quiet".
## Every note lasts one "step" (half a beat).
##
## This is an "autoload", so any screen can say `Music.play("fight")`.
## Press M (or the Select / Back button) to turn the music on or off.

const MIX_RATE := 22050.0

const SONGS := {
	# A cheerful tune for the title and robot builder screens.
	"menu": {
		"bpm": 132,
		"melody": [
			72, 76, 79, 76, 74, 77, 81, 77,
			72, 76, 79, 84, 83, 79, 76, 74,
			69, 72, 76, 72, 71, 74, 77, 74,
			72, 0, 79, 0, 72, 0, 0, 0,
		],
		# One bass note for every four steps.
		"bass": [48, 50, 48, 43, 45, 43, 48, 43],
		"kick": [0, 4],
		"snare": [],
	},
	# A fast, exciting tune for fighting.
	"fight": {
		"bpm": 160,
		"melody": [
			69, 0, 69, 72, 0, 69, 76, 74,
			72, 0, 72, 76, 0, 72, 79, 77,
			74, 0, 74, 77, 0, 74, 81, 79,
			76, 76, 0, 76, 75, 76, 79, 80,
		],
		"bass": [45, 45, 41, 41, 38, 38, 40, 40],
		"kick": [0, 4],
		"snare": [2, 6],
	},
}

var player: AudioStreamPlayer
var playback: AudioStreamGeneratorPlayback
var song_name := ""
var song: Dictionary = {}
var muted := false

var step := 0              # which note of the song we're on
var step_time := 0.0       # how long (in seconds) the current note has played
var melody_phase := 0.0    # where each wave is in its wiggle, from 0 to 1
var bass_phase := 0.0
var kick_phase := 0.0
var noise := RandomNumberGenerator.new()


func _ready() -> void:
	# Keep playing even if the game is paused.
	process_mode = Node.PROCESS_MODE_ALWAYS
	var gen := AudioStreamGenerator.new()
	gen.mix_rate = MIX_RATE
	gen.buffer_length = 0.15
	player = AudioStreamPlayer.new()
	player.stream = gen
	player.volume_db = -4.0
	add_child(player)


## Start a song. If that song is already playing, just keep going.
func play(which: String) -> void:
	if which == song_name or not SONGS.has(which):
		return
	song_name = which
	song = SONGS[which]
	step = 0
	step_time = 0.0
	# "headless" means no screen and no speakers (like when tests run),
	# so there is nobody to listen.
	if not player.playing and DisplayServer.get_name() != "headless":
		player.play()
		playback = player.get_stream_playback()


func toggle_mute() -> void:
	muted = not muted
	player.volume_db = -80.0 if muted else -4.0


func _unhandled_input(event: InputEvent) -> void:
	if event.is_action_pressed("music_toggle"):
		toggle_mute()


func _process(_delta: float) -> void:
	if playback == null or song.is_empty():
		return
	var frames := playback.get_frames_available()
	if frames > 0:
		playback.push_buffer(make_samples(frames))


## Work out the next `count` sound samples of the song.
func make_samples(count: int) -> PackedVector2Array:
	var out := PackedVector2Array()
	out.resize(count)
	if song.is_empty():
		return out
	var step_len: float = 60.0 / song.bpm / 2.0
	var melody: Array = song.melody
	var dt := 1.0 / MIX_RATE
	for i in range(count):
		var bar_step := step % 8
		var mnote: int = melody[step % melody.size()]
		var bnote: int = song.bass[int(step / 4.0) % song.bass.size()]
		var s := 0.0

		# Melody: a "square" wave that jumps up and down. Buzzy and bright!
		if mnote > 0:
			melody_phase = fmod(melody_phase + _freq(mnote) * dt, 1.0)
			var fade := maxf(0.0, 1.0 - step_time / step_len)
			s += (0.12 if melody_phase < 0.5 else -0.12) * fade

		# Bass: a "triangle" wave that slides up and down. Soft and round.
		bass_phase = fmod(bass_phase + _freq(bnote) * dt, 1.0)
		var tri := 4.0 * absf(bass_phase - 0.5) - 1.0
		s += tri * 0.16 * maxf(0.3, 1.0 - step_time / step_len)

		# Drums: a kick is a quick low "boom", a snare is a burst of hiss.
		if bar_step in song.kick and step_time < 0.12:
			kick_phase = fmod(kick_phase + (150.0 - step_time * 900.0) * dt, 1.0)
			s += sin(kick_phase * TAU) * 0.3 * (1.0 - step_time / 0.12)
		if bar_step in song.snare and step_time < 0.08:
			s += noise.randf_range(-0.12, 0.12) * (1.0 - step_time / 0.08)

		out[i] = Vector2(s, s)
		step_time += dt
		if step_time >= step_len:
			step_time -= step_len
			step = (step + 1) % melody.size()
			kick_phase = 0.0
	return out


## Turn a note number into how many wiggles per second it makes.
func _freq(note: int) -> float:
	return 440.0 * pow(2.0, (note - 69) / 12.0)
