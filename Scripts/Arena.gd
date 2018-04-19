extends Node2D

const PULSE_DELAY = 2
const MAX_PULSES = 3
const SCORE_TEXT = "GRACZ %s: %s"
const TIME_TEXT = "POZOSTAŁY CZAS: %s"
const BACKGROUND_W = 3508
const BACKGROUND_H = 2480

var pulse = load("res://Nodes/Pulse.tscn")
var ui
var timer
var crown
var started

onready var time_left = get_parent().settings.time
var pulse_delay = 0
var occupied = []
var occupcount = 0

var players_score = [0, 0, 0, 0]
var highest_score = 0

func _ready():
	$"../Camera".limit_left = -BACKGROUND_W/2
	$"../Camera".limit_right = BACKGROUND_W/2
	$"../Camera".limit_top = -BACKGROUND_H/2
	$"../Camera".limit_bottom = BACKGROUND_H/2
	
	var players = 0
	for i in get_parent().players_joined: if i > -1: players += 1
	
	occupied.resize($PulseSpawners.get_child_count())
	get_parent().connect("start", self, "start")
	
	ui = get_parent().register_UI($Scores, self)
	timer = get_parent().register_UI($Time, self)
	crown = get_parent().register_UI($Crown, self)
	for i in range(ui.get_children().size()):
		ui.get_child(i).visible = get_parent().players_joined[i] > -1
	timer.text = TIME_TEXT % str(ceil(time_left))
	
	$Arena/Background.set_texture_size(BACKGROUND_W, BACKGROUND_H)

func _process(delta):
	if !started: return
	
	if pulse_delay <= 0 and occupcount < MAX_PULSES:#occupied.size():
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
	camera.position = Vector2()
	camera.zoom = Vector2(3, 3)
	return true