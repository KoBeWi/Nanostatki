extends Node

const START = 0.4
const ARENA_SIZE = 764
const ARENA_COLORS = {Color(1, 1, 0): Color(1, 0.5, 0), Color(0, 1, 0): Color(0.5, 1, 0), Color(0, 1, 1): Color(0.25, 0.5, 1), Color(1, 0, 1): Color(0.5, 0, 1)}

onready var players = $"../Players"
var wintext

var win = -1

func _ready():
	$Inside/Shape.shape.radius = ARENA_SIZE
	
	var teams = []
	var players = 0
	for i in range(4): if get_parent().players_joined[i] > -1:
		players += 1
		teams.append(i)
	
	var deg = 360 / players
	for i in range(players):
		var point = $StartingPositions.get_child(teams[i])
		point.position = Vector2(cos(deg2rad(i * deg)) * ARENA_SIZE * START, sin(deg2rad(i * deg)) * ARENA_SIZE * START)
		point.rotation_degrees = deg * i + 180
		
		var piece = $Arena.get_child(i)
		piece.visible = true
		piece.modulate = ARENA_COLORS[Com.PLAYER_COLORS[teams[i]]]
		piece.texture = Com.sumo_arenas[(players-2)*4 + i]
	
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