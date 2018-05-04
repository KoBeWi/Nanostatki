extends Node2D

var players
var names = ["", "", "", ""]
var spots = [-1, -1, -1, -1]
var scores
var mode

func _ready():
	Jukebox.stop()

func setup(_players, _scores, scoreboard):
	Com.load_scoreboard(scoreboard)
	players = _players
	scores = _scores
	for _mode in Com.MODES: if scoreboard.find(_mode) > -1: mode = _mode
	
	for i in range(4):
		if _players[i] > -1:
			spots[i] = Com.add_score("", _scores[i])
			
			for j in range(i):
				if spots[i] < spots[j]: spots[j] += 1
	
	for i in range(4):
		var spot = get_node("Player" + str(i+1))
		spots[i] = Com.locate_score(_scores[i])
		
		if _players[i] > -1:
			match mode:
				"Race":
					spot.get_node("Score").text = " Czas: " + Com.format_time(-_scores[i])
					spot.get_node("Rank").text = "Miejsce w rankingu: " + str(spots[i]+1)
		else:
			spot.visible = false

func _process(delta):
	if Input.is_action_just_pressed("ui_accept"):
		for i in range(4):
			if players[i] > -1:
				Com.update_name(spots[i], names[i])
		
		Com.save_scoreboard()