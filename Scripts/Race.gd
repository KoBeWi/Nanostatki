extends Node2D

const FOLLOWER_SPEED = 100
const FOLLOWER_ITERATIONS = 5

export var lap_length = 0
var laps = [0, 0, 0, 0]

func _ready():
	var background = Com.race_backgrounds[randi() % Com.race_backgrounds.size()]
	$"Track/Background".texture = background 
	$"../Camera".limit_left = -background.get_width()/2
	$"../Camera".limit_right = background.get_width()/2
	$"../Camera".limit_top = -background.get_height()/2
	$"../Camera".limit_bottom = background.get_height()/2

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
		
		if player.race_distance > lap_length * (laps[player.team] + 1):
			laps[player.team] += 1

func process_camera(camera, players):
	var player = players[0]
	var x_diff = 0
	var y_diff = 0
	
	for _player in players:
		if _player.race_distance > player.race_distance: player = _player
		
	for _player in players:
		x_diff = max(abs(_player.position.x - player.position.x) + get_parent().CAMERA_OFFSET, x_diff)
		y_diff = max(abs(_player.position.y - player.position.y) + get_parent().CAMERA_OFFSET, y_diff)
	
	camera.position = player.position
	var new_zoom = max(min(max(x_diff / 500, y_diff / 300), 4), 1)
	camera.zoom = Vector2(new_zoom, new_zoom)
		
	return true