extends Node2D

const FOLLOWER_SPEED = 100
const FOLLOWER_ITERATIONS = 5
const BACKGROUND_W = 5760
const BACKGROUND_H = 3240

var ui

export var lap_length = 0
var laps = [0, 0, 0, 0]
var won = []
var start_time = 0

onready var camera_track = $TrackPath/CameraTrack

func _ready():
	$"../Camera".limit_left = -BACKGROUND_W/2
	$"../Camera".limit_right = BACKGROUND_W/2
	$"../Camera".limit_top = -BACKGROUND_H/2
	$"../Camera".limit_bottom = BACKGROUND_H/2
	
	ui = load("res://Nodes/RaceUI.tscn").instance()
	add_child(ui)
	ui = get_parent().register_UI(ui, self)
	ui.init_game(lap_length, get_parent().settings.laps)
	get_parent().connect("init_players", ui, "init_players")
	get_parent().connect("start", self, "race_start")

func race_start():
	start_time = OS.get_ticks_msec()
	ui.start(start_time)

func _process(delta):
	for player in $"../Players".get_children():
		var follower = get_node("TrackPath/Player" + str(player.team) + "Follower")
		var start_offset = follower.offset
		var current_dist = player.position.distance_squared_to(follower.position)
		
		for i in range(FOLLOWER_ITERATIONS):
			follower.offset = start_offset + FOLLOWER_SPEED*i
			var plus_dist = player.position.distance_squared_to(follower.position)
			follower.offset = start_offset - FOLLOWER_SPEED*i
			var minus_dist = player.position.distance_squared_to(follower.position)
			follower.offset = start_offset
			
			if plus_dist < current_dist: follower.offset = start_offset + FOLLOWER_SPEED*i
			elif minus_dist < current_dist: follower.offset = start_offset - FOLLOWER_SPEED*i
			else: follower.offset = start_offset
			
			if follower.offset != start_offset: break
		
		player.race_distance = follower.offset
		
		if player.race_distance >= lap_length * (laps[player.team] + 1):
			laps[player.team] += 1
			if laps[player.team] == get_parent().settings.laps:
				player.collision_mask = 0
				player.collision_layer = 0
				player.visible = false
				player.pause = true
				won.append({team = player.team, time = OS.get_ticks_msec() - start_time})
				
				ui.get_node("WinText").text = "GRACZ " + str(player.team+1) + " ZAJMUJE " + str(won.size()) + " MIEJSCE!"
				ui.get_node("WinText").modulate = Com.PLAYER_COLORS[player.team]
				ui.get_node("WinText").visible = true
				yield(get_tree().create_timer(2), "timeout")
				ui.get_node("WinText").visible = false
				
				if won.size() == $"../Players".get_child_count():
					ui.get_node("Timer").visible = false
					
					var results = ui.get_node("Results")
					results.text = ""
					for winner in won:
						results.text += "Gracz " + str(winner.team+1) + ": " + str(winner.time / 60000) + " : " + str(winner.time / 1000 % 60) + " : " + str(winner.time / 10 % 100) + "\n"
					results.visible = true
					
					ui.get_node("WinText").text = "KONIEC WYŚCIGU!"
					ui.get_node("WinText").modulate = Com.PLAYER_COLORS[won[0].team]
					ui.get_node("WinText").visible = true
					ui.get_node("End").visible = true
		
		if ui.get_node("End").visible and Input.is_action_just_pressed("ui_accept"):
			get_tree().change_scene_to(load("res://Scenes/MainMenu.tscn"))

func process_camera(camera, players):
	var player = players[0]
	
	for _player in players:
		_player.race_leader = false
		if (_player.race_distance > player.race_distance and _player.visible) or !player.visible: player = _player
	
	player.race_leader = true
	
	return false