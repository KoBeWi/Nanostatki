extends Node2D

var track = load("res://Sprites/DragRace/Track.png")
var electron = load("res://Nodes/Obstacles/Electron.tscn")
var proton = load("res://Nodes/Obstacles/Proton.tscn")

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
	for i in range(tracks.size()):
		create_particles(i, electron, Vector2(tracks[i], last_particle))
	
	distance = get_parent().register_UI($Distance, self)
	end = get_parent().register_UI($TheEnd, self)

func init_players(players):
	for player in players: player.drag_race = 1

func _process(delta):
	update()
	if !started: return
	
	if !the_end:
		var min_y = 0
		var move = [0, 0, 0, 0]
		
		for player in $"../Players".get_children():
			move[player.team] = player.position.y
			player.drag_race += move[player.team]
			player.position.y = 0
			min_y = min(player.drag_race, min_y)
		
		for particle in $Particles.get_children(): 
			particle.position.y -= move[particle.drag_track]
		
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
			last_particle -= 1600
			for i in range(tracks.size()):
				create_particles(i, electron if randi()%2 == 0 else proton, Vector2(tracks[i], last_particle))

func create_particles(track, particle, pos):
	var e = particle.instance()
	e.position = pos - Vector2(90, 0)
	e.drag_track = track
	$Particles.add_child(e)
	
	e = particle.instance()
	e.position = pos + Vector2(90, 0)
	e.drag_track = track
	$Particles.add_child(e)

func start():
	started = true

func process_camera(camera, players):
	var min_y = 0
	for player in players: min_y = min(player.position.y, min_y)
	
	camera.position = Vector2(512, min_y - 256)
	return true

func _draw():
	for i in range(tracks.size()):
		draw_texture_rect_region(track, Rect2(tracks[i] - width/2, camera.position.y - 300, 262, 600), Rect2(0, $"../Players".get_child(i).drag_race, 262, 600), self_modulate)