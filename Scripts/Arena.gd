extends Node2D

const PULSE_DELAY = 2
const MAX_PULSES = 3
const SCORE_TEXT = "GRACZ %s: %s"
const TIME_TEXT = "POZOSTAŁY CZAS: %s"
const BACKGROUND_W = 5000
const BACKGROUND_H = 5000

var pulse = load("res://Nodes/Pulse.tscn")
var ui
var timer
var crown
var started
var win

onready var time_left = get_parent().settings.time
var pulse_delay = 0
var occupied = []
var occupcount = 0

var players_score = [0, 0, 0, 0]
var highest_score = 0

signal end

func _ready():
	$"../Camera".limit_left = -BACKGROUND_W/2
	$"../Camera".limit_right = BACKGROUND_W/2
	$"../Camera".limit_top = -BACKGROUND_H/2
	$"../Camera".limit_bottom = BACKGROUND_H/2
	
	var players = 0
	for i in get_parent().players_joined: if i > -1: players += 1
	
	occupied.resize($PulseSpawners.get_child_count())
	get_parent().connect("start", self, "start")
	
	ui = get_parent().register_UI($ArenaUI, self)
	for i in range(ui.get_node("Scores").get_children().size()):
		ui.get_node("Scores").get_child(i).visible = get_parent().players_joined[i] > -1
	ui.get_node("Time").text = TIME_TEXT % str(ceil(time_left))
	
	$Arena/Background.set_texture_size(BACKGROUND_W, BACKGROUND_H)
	get_parent().music = "TONTURA"

func _process(delta):
	if !started: return
	
	if pulse_delay <= 0 and time_left > 0 and occupcount < MAX_PULSES:#occupied.size():
		var i = randi() % occupied.size()
		while occupied[i]: i = randi() % occupied.size()
		occupied[i] = true
		
		var p = pulse.instance()
		p.id = i
		p.position = $PulseSpawners.get_child(i).position
		p.connect("collected", self, "free_pulse")
		connect("end", p, "queue_free")
		
		add_child(p)
		occupcount += 1
		pulse_delay = PULSE_DELAY
	
	pulse_delay -= delta
	time_left -= delta
	
	
	if time_left <= 0 and !win:
		win = true
		emit_signal("end")
		
		ui.get_node("Time").visible = false
		ui.get_node("Wintext").visible = true
		ui.get_node("Exit").visible = true
		
		if ui.get_node("Crown").visible:
			var player
			for _player in $"../Players".get_children(): if players_score[_player.team] == highest_score: player = _player
			ui.get_node("Wintext").text = ui.get_node("Wintext").text % str(player.team+1)
			ui.get_node("Wintext").modulate = Com.PLAYER_COLORS[player.team]
		else:
			ui.get_node("Wintext").text = "REMIS!"
		
		get_parent().finished = true
	else:
		ui.get_node("Time").text = TIME_TEXT % str(ceil(time_left))
	
	if get_parent().finished and Input.is_action_just_pressed("ui_cancel"):
		var places = [0, 0, 0, 0]
		var score = [0, 0, 0, 0]
		
		for team in get_parent().players_joined:
			if team == -1: continue
			score[team] = players_score[team] / float(get_parent().settings.time)
			
			for team2 in get_parent().players_joined:
				if team2 == -1: continue
				if players_score[team] <= players_score[team2]: places[team] += 1
				
		
		get_parent().goto_summary(places, score)

func free_pulse(id, player):
	occupied[id] = false
	players_score[player] += 1
	ui.get_node("Scores/Player" + str(player+1)).text = SCORE_TEXT % [str(player+1), str(players_score[player])]
	
	if players_score[player] > highest_score:
		ui.get_node("Crown").visible = true
		ui.get_node("Crown").rect_position.x = 64 + player * 256
		highest_score = players_score[player]
	elif players_score[player] == highest_score:
		ui.get_node("Crown").visible = false
		
	occupcount -= 1

func start():
	started = true

func process_camera(camera, players):
	var cam_pos = Vector2()
	var min_y = 10000
	var min_x = 10000
	var max_y = -10000
	var max_x = -10000
	
	for player in players:
		min_y = min(player.get_pos().y - get_parent().CAMERA_OFFSET, min_y)
		min_x = min(player.get_pos().x - get_parent().CAMERA_OFFSET, min_x)
		max_y = max(player.get_pos().y + get_parent().CAMERA_OFFSET, max_y)
		max_x = max(player.get_pos().x + get_parent().CAMERA_OFFSET, max_x)
		cam_pos += player.get_pos()
	
	camera.position = cam_pos / players.size()
	
	var new_zoom = max(min(max(abs(max_x - min_x) / 680, abs(max_y - min_y) / 400), 8), 2)
	camera.zoom = Vector2(new_zoom, new_zoom)
	return true