extends Node

const PLAYER_COLORS = [Color(1, 1, 0), Color(0, 1, 0), Color(0, 1, 1), Color(1, 0, 1)]
const MODES = ["Race", "Drag", "Sumo", "Arena", "Survival"]
var TRIVIA = []

var scoreboard
var scores = []

var resources = {}

func _ready():
	var file = File.new()
	file.open("res://Resources/Trivia.txt", file.READ)
	TRIVIA = file.get_as_text().split("\n")
	file.close()

func load_nodenames():
	if !resources.has("nodenames"):
		resources.nodenames = [load("res://Sprites/UI/ModenameRace.png"), load("res://Sprites/UI/ModenameDrag.png"), load("res://Sprites/UI/ModenameSumo.png"), load("res://Sprites/UI/ModenameArena.png"), load("res://Sprites/UI/ModenameSurvival.png")]
	return resources.nodenames

func load_videos():
	if !resources.has("videos"):
		resources.videos = [load("res://Resources/Video/Video1.ogm"), null, load("res://Resources/Video/Video3.webm"), null, null]
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

func save_scoreboard():
	var file = File.new()
	file.open("user://" + scoreboard, file.WRITE)
	file.store_string(JSON.print(scores))
	file.close()

func format_time(time):
	return str(time / 60000) + " : " + str(time / 1000 % 60) + " : " + str(time / 10 % 100)