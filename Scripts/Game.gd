extends Node

onready var camera = $Camera
onready var players = $Players

const CAMERA_OFFSET = 128

var mode
var players_joined
var scene

var pause = 3

func setup(_mode, _players_joined):
	mode = _mode
	players_joined = _players_joined

func _ready():
	scene = load("res://Scenes/" + mode + ".tscn").instance()
	add_child(scene)
	
	for i in range(4):
		if players_joined[i] > -1:
			var player = load("res://Nodes/Ship.tscn").instance()
			var start = scene.get_node("StartingPositions/" + str(i+1))
			
			player.position = start.position
			player.rotation = start.rotation
			player.direction = Vector2(cos(start.rotation), sin(start.rotation))
			player.team = i
			player.player = players_joined[i]
			
			player.pause = true
			players.add_child(player)

func _physics_process(delta):
	if pause:
		pause -= delta
		
		if pause <= 0:
			for player in players.get_children(): player.pause = false
			pause = null
			$Camera/Countdown/Label.queue_free()
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
			min_y = min(player.position.y - CAMERA_OFFSET, min_y)
			min_x = min(player.position.x - CAMERA_OFFSET, min_x)
			max_y = max(player.position.y + CAMERA_OFFSET, max_y)
			max_x = max(player.position.x + CAMERA_OFFSET, max_x)
			cam_pos += player.position
		
		camera.position = cam_pos / players.get_child_count()
		
		var new_zoom = max(min(max(abs(max_x - min_x) / 1024, abs(max_y - min_y) / 600), 4), 1)
		camera.zoom = Vector2(new_zoom, new_zoom)

func register_UI(ui, old_owner):
	old_owner.remove_child(ui)
	$Camera.add_child(ui)