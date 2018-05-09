extends Node2D

const FOLLOWER_SPEED = 100
const FOLLOWER_ITERATIONS = 5
const BACKGROUND_W = 11520
const BACKGROUND_H = 6480

var ui

export var lap_length = 0
var laps = [0, 0, 0, 0]
var lap_time = [0, 0, 0, 0]
var best_lap = [100000000, 100000000, 100000000, 100000000]
var won = []
var start_time = 0
var places = [0, 0, 0, 0]

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
	
	$Track/Background.set_texture_size(BACKGROUND_W, BACKGROUND_H)
	get_parent().music = "CORTE COSTURA"

func race_start():
	start_time = OS.get_ticks_msec()
	for i in range(4): lap_time[i] = start_time
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
			var time = OS.get_ticks_msec() - lap_time[player.team]
			if time < best_lap[player.team]: best_lap[player.team] = time
			lap_time[player.team] = OS.get_ticks_msec()
			
			if laps[player.team] == get_parent().settings.laps:
				player.collision_mask = 0
				player.collision_layer = 0
				player.fade_out = true
				player.pause = true
				won.append({team = player.team, time = OS.get_ticks_msec() - start_time})
				
				ui.get_node("WinText").text = "GRACZ " + str(player.team+1) + " ZAJMUJE " + str(won.size()) + " MIEJSCE!"
				places[player.team] = won.size()
				ui.get_node("WinText").modulate = Com.PLAYER_COLORS[player.team]
				ui.get_node("WinText").visible = true
				if won.size() == $"../Players".get_child_count(): ui.get_node("Timer").visible = false
				yield(get_tree().create_timer(2), "timeout")
				ui.get_node("WinText").visible = false
				
				if !get_parent().finished and won.size() == $"../Players".get_child_count():
					get_parent().finished = true
					for i in range(4): best_lap[i] = -best_lap[i]
					yield(get_tree().create_timer(2), "timeout")
					get_parent().goto_summary(places, best_lap)

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