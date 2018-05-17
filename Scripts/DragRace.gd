extends Node2D

var track = load("res://Sprites/DragRace/Track.png")
var background = load("res://Sprites/DragRace/Background.png")
var split = load("res://Sprites/DragRace/SplitScreen.png")
var electron = load("res://Nodes/Obstacles/Electron.tscn")
var proton = load("res://Nodes/Obstacles/Proton.tscn")

var FAIL_TIME = 2


var width = track.get_width()
var tracks = [null, null, null, null]
var players = 0
var last_particle = [-400, -400, -400, -400]
var fail_time = [0, 0, 0, 0]
var last_distance = [0, 0, 0, 0]
var started = false
var the_end = false
var is_ded = 0

var distance
var end
var camera

func _ready():
	get_parent().connect("init_players", self, "init_players")
	get_parent().connect("start", self, "start")
	for i in get_parent().players_joined: if i > -1: players += 1
	
	if Com.easy_mode == true: FAIL_TIME *= 2
	
	var dx = 3072 / players
	var x0 = [0, -768, -1024, -1152][players-1]
	
	var j = 0
	for i in range(4):
		if get_parent().players_joined[i] == -1: continue
		
		tracks[i] = x0 + dx*j
		j += 1
		var point = $StartingPositions.get_child(i)
		point.position = Vector2(tracks[i], 0)
		get_node("Distance/" + str(i+1)).visible = true
		get_node("Distance/" + str(i+1)).rect_position.x = tracks[i]/3 - 96 + 512
		get_node("TheEnd/" + str(i+1)).rect_position.x = tracks[i]/3 - 192 + 512
	
	camera = $"../Camera"
	camera.smoothing_enabled = false
	
	for i in range(4):
		if tracks[i] != null: create_particles(i, electron, Vector2(tracks[i], last_particle[i]))
	
	distance = get_parent().register_UI($Distance, self)
	end = get_parent().register_UI($TheEnd, self)
	get_parent().music = "THISBASS"

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
	
		if player.drag_race >= last_distance[player.team]-100:
			fail_time[player.team] += delta
		else:
			distance.get_node(str(player.team+1)).text = str(int(max(0, -player.drag_race)))
			last_distance[player.team] = player.drag_race
			fail_time[player.team] = 0
		
		if fail_time[player.team] >= FAIL_TIME:
			player.paralyzed = true
			end.get_node(str(player.team+1)).visible = true
			is_ded += 1

		if player.drag_race < last_particle[player.team] - 100:
			if Com.easy_mode == false:
				last_particle[player.team] -= 4800 - last_particle[player.team] / 35
			else:
				last_particle[player.team] -= 4800 - last_particle[player.team] / 50
			create_particles(player.team, electron if randi()%2 == 0 else proton, Vector2(tracks[player.team], -4800))
	
	for particle in $Particles.get_children(): 
		particle.position.y -= move[particle.drag_track]
		if particle.position.y > 2400: particle.queue_free()
	
	if is_ded == players and !get_parent().finished:
		get_parent().finished = true
		var places = [0, 0, 0, 0]
		for i in range(4): last_distance[i] = -int(last_distance[i])
		
		for team in get_parent().players_joined:
			if team == -1: continue
			
			for team2 in get_parent().players_joined:
				if team2 == -1: continue
				if last_distance[team] <= last_distance[team2]: places[team] += 1
		
		yield(get_tree().create_timer(3), "timeout")
		get_parent().goto_summary(places, last_distance)

func create_particles(track, particle, pos):
	var e = particle.instance()
	e.position = pos - Vector2(110, 0)
	e.drag_track = track
	$Particles.add_child(e)
	
	e = particle.instance()
	e.position = pos + Vector2(110, 0)
	e.drag_track = track
	$Particles.add_child(e)

func start():
	started = true

func process_camera(camera, players):
	camera.position = Vector2(0, -768)
	camera.zoom = Vector2(3, 3)
	return true

func _draw():
	for i in range(4):
		if tracks[i] == null: continue
		var player
		for _player in $"../Players".get_children(): if _player.team == i: player = _player
		
		var end = fail_time[i] / FAIL_TIME
		draw_texture_rect_region(background, Rect2(tracks[i] - 3072 / players / 2, camera.position.y - 900, 3072 / players, 1800), Rect2(0, player.drag_race, 3072, 1800))
		draw_texture_rect_region(track, Rect2(tracks[i] - width/2, camera.position.y - 900, 262, 1800), Rect2(0, player.drag_race, 262, 1800), Color(1 - end, 1 - end, 1 - end))
	
	var j = 0
	var k = 1
	for i in range(players-1):
		while j < 4 and tracks[j] == null: j += 1
		while k < 4 and tracks[k] == null: k += 1
		draw_texture(split, Vector2((tracks[j] + tracks[k])/2 - split.get_width()/2, camera.position.y - 900))
		j += 1
		k += 1
