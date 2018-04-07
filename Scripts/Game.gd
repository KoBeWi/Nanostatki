extends Node

onready var camera = $Camera
onready var players = $Players

const CAMERA_OFFSET = 128

var mode
var players_joined
var scene
var settings = {}

var pause = 3

signal init_players
signal start

func setup(_mode, _players_joined, options):
	mode = _mode
	players_joined = _players_joined
	
	if mode == "Race":
		mode = "Race/Race" + str(options[0])
		settings["laps"] = options[1]
	elif mode == "Arena":
		mode = "Arena/Arena" + str(options[0])
		settings["time"] = options[1]

func _ready():
	scene = load("res://Scenes/" + mode + ".tscn").instance()
	add_child(scene)
	
	start_scene()
	
	emit_signal("init_players", players.get_children())

func _physics_process(delta):
	if pause:
		pause -= delta
		
		if pause <= 0:
			for player in players.get_children(): player.pause = false
			pause = null
			$Camera/Countdown/Label.visible = false
			emit_signal("start")
		else:
			var s = (pause - int(pause)) * 10
			$Camera/Countdown/Label.text = str(ceil(pause))
			$Camera/Countdown.scale = Vector2(s, s)
	
	if !scene.process_camera(camera, players.get_children()):
		var cam_pos = Vector2()
		var min_y = 10000
		var min_x = 10000
		var max_y = -10000
		var max_x = -10000
		
		for player in players.get_children():
			min_y = min(player.get_pos().y - CAMERA_OFFSET, min_y)
			min_x = min(player.get_pos().x - CAMERA_OFFSET, min_x)
			max_y = max(player.get_pos().y + CAMERA_OFFSET, max_y)
			max_x = max(player.get_pos().x + CAMERA_OFFSET, max_x)
			cam_pos += player.get_pos()
		
		camera.position = cam_pos / players.get_child_count()
		
		var new_zoom = max(min(max(abs(max_x - min_x) / 1024, abs(max_y - min_y) / 600), 4), 1)
		camera.zoom = Vector2(new_zoom, new_zoom)

func restart_scene():
	for player in $Players.get_children(): player.queue_free()
	pause = 3
	$Camera/Countdown/Label.visible = true
	start_scene()

func start_scene():
	for i in range(4): if players_joined[i] > -1:
		var player = load("res://Nodes/Ship.tscn").instance()
		var start = scene.get_node("StartingPositions/" + str(i+1))
		
		player.position = start.position
		player.rotation = start.rotation
		player.direction = Vector2(cos(start.rotation), sin(start.rotation))
		player.team = i
		player.player = players_joined[i]
		
		player.pause = true
		players.add_child(player)

func register_UI(ui, old_owner):
	old_owner.remove_child(ui)
	$Camera/UI.add_child(ui)
	return ui