extends Node2D

var players
var names = ["", "", "", ""]
var scores
var mode

func _ready():
	Jukebox.stop()

func setup(_players, _scores, scoreboard):
	Com.load_scoreboard(scoreboard)
	players = _players
	scores = _scores
	for _mode in Com.MODES: if scoreboard.find(_mode) > -1: mode = mode
	
	for i in range(4):
		if _players[i] > -1:
			var spot = get_node("Player" + str(i+1))
			match mode:
				"Race":
					spot.get_node("Score").text = "Wynik: " + Com.format_time(-_scores[i])
					spot.get_node("Rank").text = "Miejsce w rankingu: " + Com.locate_score(_scores[i])+1
