extends Node2D

const CAMERA_OFFSET = 128

onready var death = $WallOfDeath
onready var camera = $"/root/Game/Camera"

var health = load("res://Nodes/ShipHealth.tscn")
var electron = load("res://Nodes/Obstacles/Electron.tscn")
var proton = load("res://Nodes/Obstacles/Proton.tscn")

var start_time = 0
var distance_label
var players = [null, null, null, null]
var healths = [8, 8, 8, 8]
var distance = [0, 0, 0, 0]

func _ready():
	get_parent().connect("init_players", self, "init_players")
	
	$"/root/Game/Camera".limit_top = -1048
	$"/root/Game/Camera".limit_bottom = 1048
	
	start_time = OS.get_ticks_msec()
	distance_label = get_parent().register_UI($Distance, self)
	get_parent().music = "MAU"

func _physics_process(delta):
	var prev_maxd = 0
	var maxd = 0
	
	for player in players:
		if !player or !player.visible: continue
		if distance[player.team] > prev_maxd: prev_maxd = distance[player.team]
		
		if player.position.x > distance[player.team]:
			distance[player.team] = player.position.x
			distance_label.get_child(player.team).text = str(int(distance[player.team]))
			
			if distance[player.team] > maxd: maxd = distance[player.team]
	
	if maxd > prev_maxd and int(maxd) % 512 < int(prev_maxd) % 512:
		spawn_obstacles(int(maxd))
	
	for obstacle in $Obstacles.get_children():
		if obstacle.position.x < death.position.x - 512: obstacle.queue_free()
	
	death.position.x += (OS.get_ticks_msec() - start_time) / 10000 + 1
	camera.limit_left = death.position.x

func init_players(_players):
	for player in _players:
		distance_label.get_child(player.team).visible = true
		var hl = health.instance()
		hl.modulate = Com.PLAYER_COLORS[player.team]
		hl.connect("body_entered", self, "obstacle_hit", [player.team])
		
		player.survival = true
		player.collision_layer = 4
		player.collision_mask = 4
		player.add_child(hl)
		players[player.team] = player

func obstacle_hit(body, team):
	if body.is_in_group("obstacles"):
		var damage = 1
		if body.name == "Death": damage = 8
		
		healths[team] -= damage
		players[team].get_node("Survival/Indicator").value -= damage
		
		if healths[team] <= 0:
			players[team].visible = false

func spawn_obstacles(distance):
	distance += 2048
	
	var x = int(distance) / 512 * 512
	var y = -976 + x/512%2 * 256
	
	for i in range(4):
		var particle = (proton if randi()%2 == 0 else electron).instance()
		particle.position = Vector2(x, y + i * 568)
		$Obstacles.add_child(particle)

func process_camera(camera, players):
	var cam_pos = Vector2()
	var min_y = 1000000000
	var min_x = 1000000000
	var max_y = -1000000000
	var max_x = -1000000000
	
	var playnum = 0
	
	for player in players:
		if !player.visible: continue
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