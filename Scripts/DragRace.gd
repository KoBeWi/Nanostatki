extends Node2D

var track = load("res://Sprites/DragRace/Track.png")
var electron = load("res://Nodes/Obstacles/Electron.tscn")
var proton = load("res://Nodes/Obstacles/Proton.tscn")

var FAIL_TIME = 2

var width = track.get_width()
var tracks = []
var last_particle
var fail_time = [0, 0, 0, 0]
var last_distance = [0, 0, 0, 0]
var started = false
var the_end = false

var distance
var end
var camera

func _ready():
	get_parent().connect("init_players", self, "init_players")
	get_parent().connect("start", self, "start")
	var players = 0
	for i in get_parent().players_joined: if i > -1: players += 1
	var dx = 2048 / (players+1)
	
	for i in range(players):
		tracks.append(dx * (i+1))
		var point = $StartingPositions.get_child(i)
		point.position = Vector2(tracks.back(), 0)
		get_node("Distance/" + str(i+1)).visible = true
		get_node("Distance/" + str(i+1)).rect_position.x = tracks.back()/3 + 76
		get_node("TheEnd/" + str(i+1)).rect_position.x = tracks.back()/3 - 8
	
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
	
	var move = [0, 0, 0, 0]
	
	for player in $"../Players".get_children():
		if player.paralyzed: continue
		
		move[player.team] = player.position.y
		player.drag_race += move[player.team]
		player.position.y = 0
	
		if player.drag_race >= last_distance[player.team]:
			fail_time[player.team] += delta
		else:
			distance.get_node(str(player.team+1)).text = str(int(max(0, -player.drag_race)))
			last_distance[player.team] = player.drag_race
			fail_time[player.team] = 0
		
		if fail_time[player.team] >= FAIL_TIME:
			player.paralyzed = true
			end.get_node(str(player.team+1)).visible = true

		if player.drag_race < last_particle + 100:
			last_particle -= max(100, 1600 - last_particle / 1000)
			for i in range(tracks.size()):
				create_particles(i, electron if randi()%2 == 0 else proton, Vector2(tracks[i], last_particle))
	
	for particle in $Particles.get_children(): 
		particle.position.y -= move[particle.drag_track]

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
	camera.position = Vector2(1024, -768)
	camera.zoom = Vector2(3, 3)
	return true

func _draw():
	for i in range(tracks.size()):
		var player = $"../Players".get_child(i)
		var end = fail_time[player.team] / FAIL_TIME
		draw_texture_rect_region(track, Rect2(tracks[i] - width/2, camera.position.y - 900, 262, 1800), Rect2(0, player.drag_race, 262, 1800), Color(1 - end, 1 - end, 1 - end))