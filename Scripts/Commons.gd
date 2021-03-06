extends Node

const PLAYER_COLORS = [Color("9e2525"), Color("0082d3"), Color("679300"), Color("eab334")]
const MODES = ["Race", "Drag", "Sumo", "Arena", "Survival"]
var TRIVIA = []
var SAMPLE2D = load("res://Nodes/SampleInstance.tscn")
var SAMPLE = load("res://Nodes/IndependentSampleInstance.tscn")

var mute_music
var easy_mode = false

var scoreboard
var scores = []
var resources = {}

func _ready():
	randomize()
	var file = File.new()
	file.open("res://Resources/Trivia.txt", file.READ)
	TRIVIA = file.get_as_text().split("\n")
	file.close()
	
	var f = File.new()
	if f.open("user://fullscreen", f.READ) == OK: OS.window_fullscreen = true
	if f.open("user://mute_music", f.READ) == OK: mute_music = true

func _process(delta):
	if Input.is_action_just_pressed("fullscreen"):
		OS.window_fullscreen = !OS.window_fullscreen
		save_setting("setting", OS.window_fullscreen)
			
	if Input.is_action_just_pressed("mute_music"):
		mute_music = !mute_music
		save_setting("mute_music", mute_music)
		
		if mute_music:
			Jukebox.stop()
		else:
			Jukebox.play()

func save_setting(setting, set):
	if set:
		var f = File.new()
		f.open("user://" + setting, f.WRITE)
	else:
		var d = Directory.new()
		d.remove("user://" + setting)

func load_nodenames():
	if !resources.has("nodenames"):
		resources.nodenames = [load("res://Sprites/UI/ModenameRace.png"), load("res://Sprites/UI/ModenameDrag.png"), load("res://Sprites/UI/ModenameSumo.png"), load("res://Sprites/UI/ModenameArena.png"), load("res://Sprites/UI/ModenameSurvival.png")]
	return resources.nodenames

func load_videos():
	if !resources.has("videos"):
		resources.videos = [null, null, null, null, null]
	return resources.videos

func load_tracks():
	if !resources.has("tracks"):
		resources.tracks = []
		for i in range(2): resources.tracks.append(load("res://Sprites/Race/Track" + str(i+1) + "/Border.png"))
	return resources.tracks

func load_arenas():
	if !resources.has("arenas"):
		resources.arenas = []
		for i in range(7): resources.arenas.append(load("res://Sprites/Arena/Arena" + str(i+1) + "/Border.png"))
	return resources.arenas

func load_dots():
	if !resources.has("dots"):
		resources.dots = []
		for i in range(6): resources.dots.append(load("res://Sprites/UI/MenuDot" + str(i+1) + ".png"))
	return resources.dots

func load_scoreboard(name):
	scoreboard = name
	scores = []
	
	var file = File.new()
	if file.open("user://" + name, file.READ) == OK:
		scores = parse_json(file.get_as_text())
		file.close()

func add_score(name, score):
	var pos = scores.size()
	
	for i in range(scores.size()): if score >= scores[i].score:
		pos = i
		break
	
	scores.insert(pos, {"name": name, "score": score})
	return pos

func locate_score(score):
	for i in range(scores.size()): if score >= scores[i].score: return i
	return scores.size()

func update_name(pos, name):
	scores[pos].name = name

func get_score(pos):
	if scores.size() > pos: return scores[pos]

func score_count(): return scores.size()

func save_scoreboard():
	var file = File.new()
	file.open("user://" + scoreboard, file.WRITE)
	file.store_string(JSON.print(scores))
	file.close()

func format_time(time):
	return str(time / 60000) + " : " + str(time / 1000 % 60) + " : " + str(time / 10 % 100)

func round_float(number, digits):
	var magnitude = pow(10, digits)
	return float(int(number * magnitude)) / magnitude

func play_sample(source, _sample, _2d = true):
	var sample = (SAMPLE2D if _2d else SAMPLE).instance()
	add_child(sample)
	if _2d: sample.position = source.position
	
	if not resources.has(_sample): resources[_sample] = load("res://Samples/" + _sample + ".ogg")
	sample.stream = resources[_sample]
	sample.play()
	
	return weakref(sample)