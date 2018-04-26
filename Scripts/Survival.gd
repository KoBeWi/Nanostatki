extends Node2D

const CAMERA_OFFSET = 128

onready var death = $WallOfDeath
onready var camera = $"/root/Game/Camera"

var health = load("res://Nodes/ShipHealth.tscn")
var electron = load("res://Nodes/Obstacles/Electron.tscn")
var proton = load("res://Nodes/Obstacles/Proton.tscn")

var distance = 0
var distance_label
var players = [null, null, null, null]
var healths = [8, 8, 8, 8]

func _ready():
	get_parent().connect("init_players", self, "init_players")
	
	$"/root/Game/Camera".limit_top = -1048
	$"/root/Game/Camera".limit_bottom = 1048
	
	distance_label = get_parent().register_UI($Distance, self)

func _physics_process(delta):
	var prevd = distance
	distance = max(distance, $"../Players".get_child(0).position.length())
	if distance > prevd:
		distance_label.text = "POKONANY DYSTANS: " + str(int(distance))
	
		if int(distance) % 512 < int(prevd) % 512:
			spawn_obstacles(int(distance), $"../Players".get_child(0).position, $"../Players".get_child(0).direction)
	
	death.position.x += 1
	camera.limit_left = death.position.x

func init_players(_players):
	for player in _players:
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
		healths[team] -= 1
		players[team].get_node("Survival/Indicator").value -= 1

func spawn_obstacles(distance, pos, dir):
	pos.x += 2048
	
	var x = int(pos.x) / 512 * 512
	var y = int(pos.y) / 512 * 512 - 1280 + x/512%2 * 256
	
	for i in range(10):
		var particle = (proton if randi()%2 == 0 else electron).instance()
		particle.position = Vector2(x, y + i * 512)
		
		add_child(particle)

func process_camera(camera, players):
	var cam_pos = Vector2()
	var min_y = 1000000000
	var min_x = 1000000000
	var max_y = -1000000000
	var max_x = -1000000000
	
	for player in players:
		min_y = min(player.get_pos().y - CAMERA_OFFSET, min_y)
		min_x = min(player.get_pos().x - CAMERA_OFFSET, min_x)
		max_y = max(player.get_pos().y + CAMERA_OFFSET, max_y)
		max_x = max(player.get_pos().x + CAMERA_OFFSET, max_x)
		cam_pos += player.get_pos()
	
	camera.position = cam_pos / players.size()
	
	var new_zoom = max(min(max(abs(max_x - min_x) / 680, abs(max_y - min_y) / 400), 8), 2)
	camera.zoom = Vector2(new_zoom, new_zoom)
	return true