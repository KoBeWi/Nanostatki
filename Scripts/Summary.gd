extends Node2D

const CAN_NAME = {Race = 9, Drag = 9, Sumo = 9, Arena = 4, Survival = 9}
const PLACE_COLORS = [Color("ffd300"), Color("a3a3a3"), Color("5f3200"), Color(0, 0, 0, 0)]

var players
var names = ["", "", "", ""]
var spots = [-1, -1, -1, -1]
var places
var scores
var mode
var name_queue = []

func _ready():
	Jukebox.stop()

func setup(_players, _places, _scores, scoreboard):
	if Com.easy_mode: for i in range(_scores.size()): _scores[i] /= 10
	
	Com.load_scoreboard(scoreboard)
	players = _players
	places = _places
	scores = _scores
	for _mode in Com.MODES: if scoreboard.find(_mode) > -1: mode = _mode
	
	for i in range(4):
		if _players[i] > -1:
			spots[i] = Com.add_score("", _scores[i])
			
			for j in range(i):
				if spots[i] <= spots[j]: spots[j] += 1
	
	for i in range(4):
		var spot = get_node("Player" + str(i+1))
		
		if _players[i] > -1:
			if spots[i] < CAN_NAME[mode]: name_queue.append(i)
			spot.get_node("Place").self_modulate = PLACE_COLORS[places[i]-1]
			if places[i] < 4: spot.get_node("Place/Number").self_modulate = PLACE_COLORS[places[i]-1]
			spot.get_node("Place/Number").text = str(places[i])
			spot.get_node("Rank").text = "Miejsce w rankingu: " + str(spots[i]+1) + " z " + str(Com.score_count())
			
			match mode:
				"Race":
					spot.get_node("Score").text = " Czas: " + Com.format_time(-_scores[i])
				"Drag", "Survival":
					spot.get_node("Score").text = " Dystans: " + str(_scores[i]) + "nm"
				"Sumo":
					spot.get_node("Score").text = " Wynik: " + str(_scores[i]) + "pkt"
				"Arena":
					spot.get_node("Score").text = " Szybk.: " + str(Com.round_float(_scores[i], 3)) + "pkt/s"
					$EnterName/NameInput.max_length = 8
		else:
			spot.visible = false
	
	set_player()

func _process(delta):
	if !name_queue.empty():
		$EnterName/NameInput.grab_focus()
		$EnterName/TheName.text = $EnterName/NameInput.text + ("" if OS.get_ticks_msec() % 1000 < 500 else "|")
		
		if Input.is_key_pressed(KEY_ENTER) and $EnterName/NameInput.text != "":
			names[name_queue.front()] = $EnterName/NameInput.text
			name_queue.pop_front()
			set_player()
	else:
		$EnterName.visible = false
		$RealAnyKey.visible = true
	
		if Input.is_action_just_pressed("ui_accept"):
			for i in range(4):
				if players[i] > -1:
					Com.update_name(spots[i], names[i])
			
			Com.save_scoreboard()
			
			var menu = load("res://Scenes/MainMenu.tscn").instance()
			$"/root".add_child(menu)
			menu.goto_lobby(Com.MODES.find(mode), true)
			menu.get_node("Camera").current = true
			get_tree().current_scene = menu
			queue_free()

func set_player():
	if name_queue.empty(): return
	
	var i = name_queue.front()
	$EnterName.text = "GRACZ " + str(i+1) + " WPISZ SWOJE IMIĘ:"
	$EnterName.modulate = Com.PLAYER_COLORS[i]
	$EnterName/NameInput.text = ""