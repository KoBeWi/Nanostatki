extends Node2D

var track = load("res://Sprites/DragRace/Track.png")
var electron = load("res://Nodes/Electron.tscn")
var proton = load("res://Nodes/Proton.tscn")

const DISTANCE_TEXT = "POKONANY DYSTANS: %s"
var FAIL_TIME = 2

var width = track.get_width()
var tracks = []
var last_particle
var fail_time = 0
var last_distance = 0
var started = false
var the_end = false

var distance
var end
var camera

func _ready():
	var players = 0
	get_parent().connect("init_players", self, "init_players")
	get_parent().connect("start", self, "start")
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
	
	distance = get_parent().register_UI($Distance, self)
	end = get_parent().register_UI($TheEnd, self)

func init_players(players):
	for player in players: player.drag_race = true

func _process(delta):
	update()
	if !started: return
	
	if !the_end:
		var min_y = 0
		for player in $"../Players".get_children(): min_y = min(player.position.y, min_y)
		
		if min_y >= last_distance:
			fail_time += delta
		else:
			distance.text = DISTANCE_TEXT % str(int(max(0, -min_y)))
			last_distance = min_y
			fail_time = 0
		
		if fail_time >= FAIL_TIME:
			end.visible = true
			the_end = true
	
		if min_y < last_particle + 100:
			last_particle -= 600
			for track in tracks: create_particles(electron if randi()%2 == 0 else proton, Vector2(track, last_particle))

func create_particles(particle, pos):
	var e = particle.instance()
	e.position = pos - Vector2(90, 0)
	$Partcles.add_child(e)
	
	e = particle.instance()
	e.position = pos + Vector2(90, 0)
	$Partcles.add_child(e)

func start():
	started = true

func process_camera(camera, players):
	var min_y = 0
	for player in players: min_y = min(player.position.y, min_y)
	
	camera.position = Vector2(512, min_y - 256)
	return true

func _draw():
	for tr in tracks:
		draw_texture(track, Vector2(tr - width/2, camera.position.y - 300))