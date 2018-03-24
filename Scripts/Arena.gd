extends Node2D

const PULSE_DELAY = 2
const SCORE_TEXT = "GRACZ %s: %s"
const TIME_TEXT = "POZOSTAŁY CZAS: %s"

var pulse = load("res://Nodes/Pulse.tscn")
var ui
var timer
var crown
var started

var time_left = 30
var pulse_delay = 0
var occupied = []
var occupcount = 0

var players_score = [0, 0, 0, 0]
var highest_score = 0

func _ready():
	var players = 0
	for i in get_parent().players_joined: if i > -1: players += 1
	
	var deg = 360 / players
	for i in range(players):
		var point = $StartingPositions.get_child(i)
		point.position = Vector2(cos(deg2rad(i * deg)) * 400, sin(deg2rad(i * deg)) * 400)
		point.rotation_degrees = deg * i + 180
	
	occupied.resize($PulseSpawners.get_child_count())
	get_parent().connect("start", self, "start")
	
	ui = get_parent().register_UI($Scores, self)
	timer = get_parent().register_UI($Time, self)
	crown = get_parent().register_UI($Crown, self)
	for i in range(ui.get_children().size()):
		ui.get_child(i).visible = get_parent().players_joined[i] > -1
	timer.text = TIME_TEXT % str(ceil(time_left))

func _process(delta):
	if !started: return
	
	if pulse_delay <= 0 and occupcount < occupied.size():
		var i = randi() % occupied.size()
		while occupied[i]: i = randi() % occupied.size()
		occupied[i] = true
		
		var p = pulse.instance()
		p.id = i
		p.position = $PulseSpawners.get_child(i).position
		p.connect("collected", self, "free_pulse")
		
		add_child(p)
		occupcount += 1
		pulse_delay = PULSE_DELAY
	
	pulse_delay -= delta
	time_left -= delta
	
	timer.text = TIME_TEXT % str(ceil(time_left))

func free_pulse(id, player):
	occupied[id] = false
	players_score[player] += 1
	ui.get_node("Player" + str(player+1)).text = SCORE_TEXT % [str(player+1), str(players_score[player])]
	
	if players_score[player] > highest_score:
		crown.visible = true
		crown.rect_position.x = 64 + player * 256
		highest_score = players_score[player]
	elif players_score[player] == highest_score:
		crown.visible = false
		
	occupcount -= 1

func start():
	started = true

func process_camera(camera, players):
	pass