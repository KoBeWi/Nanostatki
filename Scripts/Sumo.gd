extends Node

const START = 0.4

func _ready():
	var arena_size = $Arena.texture.get_width()/2
	$Inside/Shape.shape.radius = arena_size
	
	var players = 0
	for i in get_parent().players_joined: if i > -1: players += 1
	
	var deg = 360 / players
	for i in range(players):
		var point = $StartingPositions.get_child(i)
		point.position = Vector2(cos(deg2rad(i * deg)) * arena_size * START, sin(deg2rad(i * deg)) * arena_size * START)
		point.rotation_degrees = deg * i + 180

func process_camera(camera, players):
	pass

func _player_left(body):
	if body.is_in_group("players") and $"../Players".get_child_count() > 1:
		body.queue_free()