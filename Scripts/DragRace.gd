extends Node2D

var track = load("res://Sprites/DragRace/Track.png")
var electron = load("res://Nodes/Electron.tscn")
var proton = load("res://Nodes/Proton.tscn")

const DISTANCE_TEXT = "Pokonany dystans: %s"

var width = track.get_width()
var tracks = []
var distance
var camera
var last_particle

func _ready():
	var players = 0
	get_parent().connect("init_players", self, "init_players")
	for i in get_parent().players_joined: if i > -1: players += 1
	var dx = 1024 / (players+1)
	
	for i in range(players):
		tracks.append(dx * (i+1))
		var point = $StartingPositions.get_child(i)
		point.position = Vector2(tracks.back(), 0)
	
	camera = $"../Camera"
	camera.smoothing_enabled = false
	
	last_particle = -400
	for track in tracks: create_particles(electron, Vector2(track, last_particle))
	
	distance = $Distance
	get_parent().register_UI(distance, self)

func init_players(players):
	for player in players: player.drag_race = true

func _process(delta):
	var min_y = 0
	for player in $"../Players".get_children(): min_y = min(player.position.y, min_y)
	distance.text = DISTANCE_TEXT % str(int(max(0, -min_y)))
	
	if min_y < last_particle + 100:
		last_particle -= 600
		for track in tracks: create_particles(electron if randi()%2 == 0 else proton, Vector2(track, last_particle))
	
	update()

func create_particles(particle, pos):
	var e = particle.instance()
	e.position = pos - Vector2(90, 0)
	$Partcles.add_child(e)
	
	e = particle.instance()
	e.position = pos + Vector2(90, 0)
	$Partcles.add_child(e)

func process_camera(camera, players):
	var min_y = 0
	for player in players: min_y = min(player.position.y, min_y)
	
	camera.position = Vector2(512, min_y - 256)
	return true

func _draw():
	for tr in tracks:
		draw_texture(track, Vector2(tr - width/2, camera.position.y - 300))