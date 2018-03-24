extends Node

const START = 0.4

onready var players = $"../Players"
var wintext

var win = -1

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
	
	wintext = get_parent().register_UI($WinText, self)

func _process(delta):
	if win == -1 and players.get_child_count() == 1:
		var player = players.get_child(0)
		player.pause = true
		win = player.team
		
		wintext.visible = true
		wintext.text = wintext.text % str(player.team+1)
		wintext.modulate = Com.PLAYER_COLORS[win]

func process_camera(camera, players):
	if win > -1:
		camera.position = Vector2()
		camera.zoom = Vector2(3, 3)
		return true

func _player_left(body):
	if body.is_in_group("players") and players.get_child_count() > 1:
		body.queue_free()