extends Node2D

var track = load("res://Sprites/DragRace/Track.png")
var electron = load("res://Nodes/Electron.tscn")
var proton = load("res://Nodes/Electron.tscn")

var width = track.get_width()
var tracks = []
var camera

func _ready():
	var players = 1
	var dx = 1024 / (players+1)
	
	for i in range(players):
		tracks.append(dx * (i+1))
		var point = $StartingPositions.get_child(i)
		point.position = Vector2(tracks.back(), 0)
	
	camera = $"../Camera"
	camera.smoothing_enabled = false
	
	for track in tracks:
		create_particle(electron, Vector2(track - 90, -400))
		create_particle(electron, Vector2(track + 90, -400))

func _process(delta):
	for player in $"../Players".get_children(): player.drag_race = true
	
	update()

func create_particle(particle, pos):
	var e = particle.instance()
	e.position = pos
	$Partcles.add_child(e)

func process_camera(camera, players):
	var min_y = 0
	for player in players:
		min_y = min(player.position.y, min_y)
	
	camera.position = Vector2(512, min_y - 256)
	return true

func _draw():
	for tr in tracks:
		draw_texture(track, Vector2(tr - width/2, camera.position.y - 300))