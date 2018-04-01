extends Node2D

var health = load("res://Nodes/ShipHealth.tscn")

var distance = 0
var distance_label
var players = [null, null, null, null]
var healths = [8, 8, 8, 8]

func _ready():
	get_parent().connect("init_players", self, "init_players")
	
	distance_label = get_parent().register_UI($Distance, self)

func _physics_process(delta):
	var prevd = distance
	distance = max(distance, $"../Players".get_child(0).position.length())
	if distance > prevd: distance_label.text = "POKONANY DYSTANS: " + str(int(distance))

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

func process_camera(camera, players):
	pass