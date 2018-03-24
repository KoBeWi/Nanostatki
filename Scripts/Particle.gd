extends KinematicBody2D

const FORCE = 25000
const MIN_FORCE = 5

onready var players = $"/root/Game/Players"

export var charge = 1

func _ready():
	pass

func _physics_process(delta):
	for player in players.get_children():
		if player.pause: break
		
		var force = (position - player.position) / position.distance_squared_to(player.position) * FORCE * charge * player.charge
		if force.length() > MIN_FORCE: player.velocity -= force