extends Node2D

const CAMERA_OFFSET = 128
var PARTICLE_DISTANCE = 2048

onready var death = $WallOfDeath
onready var camera = $"/root/Game/Camera"

var health = load("res://Nodes/ShipHealth.tscn")
var damage_fx = load("res://Nodes/Effects/ShipDamage.tscn")
var electron = load("res://Nodes/Obstacles/Electron.tscn")
var proton = load("res://Nodes/Obstacles/Proton.tscn")

var start_time = 0
var distance_label
var players = [null, null, null, null]
var healths = [8, 8, 8, 8]
var distance = [0, 0, 0, 0]
var the_end
var explosion
var started

func _ready():
	get_parent().connect("init_players", self, "init_players")
	get_parent().connect("start", self, "start")
	
	$"/root/Game/Camera".limit_top = -1048
	$"/root/Game/Camera".limit_bottom = 1048
	
	distance_label = get_parent().register_UI($Distance, self)
	the_end = get_parent().register_UI($AllThingsDone, self)
	explosion = get_parent().register_UI($Explosion, self)
	get_parent().music = "MAU"

func start():
	started = true

func _physics_process(delta):
	if !started: start_time = OS.get_ticks_msec()
	var prev_maxd = 0
	var maxd = 0
	
	for player in players:
		if !player: continue
		if distance[player.team] > prev_maxd: prev_maxd = distance[player.team]
		
		if player.position.x > distance[player.team]:
			distance[player.team] = player.position.x
			distance_label.get_child(player.team).text = str(int(distance[player.team]))
			
			if distance[player.team] > maxd: maxd = distance[player.team]
	
	if maxd > prev_maxd and int(maxd) % PARTICLE_DISTANCE < int(prev_maxd) % PARTICLE_DISTANCE:
		spawn_obstacles(int(maxd))
		PARTICLE_DISTANCE = max(PARTICLE_DISTANCE - 50 + randi() % 50, 512)
	
	for obstacle in $Obstacles.get_children():
		if obstacle.position.x < death.position.x - 512: obstacle.queue_free()
	
	death.position.x += min((OS.get_ticks_msec() - start_time) / 3000 + 1, 16)
	camera.limit_left = death.position.x
	
	if get_parent().finished:
		the_end.modulate.a += delta

func init_players(_players):
	for player in _players:
		distance_label.get_child(player.team).visible = true
		var hl = health.instance()
		hl.modulate = Com.PLAYER_COLORS[player.team]
		hl.connect("body_entered", self, "obstacle_hit", [player.team])
		
		player.survival = explosion
		player.collision_layer = 4
		player.collision_mask = 4
		player.add_child(hl)
		players[player.team] = player

func obstacle_hit(body, team):
	if body.is_in_group("obstacles") and players[team]:
		var damage = 1
		if body.name == "Death":
			Com.play_sample(body, "Darkness", false)
			damage = 8
		
		healths[team] -= damage
		players[team].get_node("Survival/Indicator").value -= damage
		
		if healths[team] <= 0:
			if body.name != "Death":
				players[team].explode()
				players[team].connect("exploded", self, "trigger_dead")
			else:
				players[team] = null
				trigger_dead()
			players[team] = null
		else:
			Com.play_sample(body, "Damage"+str(1+randi()%4), false)
			var fx = damage_fx.instance()
			fx.emitting = true
			add_child(fx)
			fx.position = players[team].position
			get_tree().create_timer(1).connect("timeout", fx, "queue_free")

func spawn_obstacles(distance):
	distance += 2048
	
	var x = int(distance) / PARTICLE_DISTANCE * PARTICLE_DISTANCE
	var mover = preload("res://Nodes/ParticleMover.tscn").instance()
	mover.position = Vector2(x, 0)
	mover.phase = randf() * 10
	mover.speed = x / 10000.0
	var particle = (proton if randi()%2 == 0 else electron).instance()
	mover.add_child(particle)
	$Obstacles.add_child(mover)
	
	return
	var y = -976 + x/512%2 * 256
	
#	for i in range(4):
#		var particle = (proton if randi()%2 == 0 else electron).instance()
#		particle.position = Vector2(x, y + i * 568)
#		$Obstacles.add_child(particle)

func process_camera(camera, players):
	var cam_pos = Vector2()
	var min_y = 1000000000
	var min_x = 1000000000
	var max_y = -1000000000
	var max_x = -1000000000
	
	var playnum = 0
	
	for player in players:
		playnum += 1
		
		min_y = min(player.get_pos().y - CAMERA_OFFSET, min_y)
		min_x = min(player.get_pos().x - CAMERA_OFFSET, min_x)
		max_y = max(player.get_pos().y + CAMERA_OFFSET, max_y)
		max_x = max(player.get_pos().x + CAMERA_OFFSET, max_x)
		cam_pos += player.get_pos()
	
	if playnum == 0: return true
	
	camera.position = cam_pos / playnum
	
	var new_zoom = max(min(max(abs(max_x - min_x) / 680, abs(max_y - min_y) / 400), 3.5), 2)
	camera.zoom = Vector2(new_zoom, new_zoom)
	return true

func trigger_dead():
	var all_dead = true
	for player in players:
		if player: all_dead = false
	
	if all_dead:
		get_parent().finished = true
		yield(get_tree().create_timer(2), "timeout")
		
		var places = [0, 0, 0, 0]
		
		for team in get_parent().players_joined:
			if team == -1: continue
			
			for team2 in get_parent().players_joined:
				if team2 == -1: continue
				if distance[team] <= distance[team2]: places[team] += 1
		
		for i in range(4): distance[i] = int(distance[i])
		get_parent().goto_summary(places, distance)