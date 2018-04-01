extends KinematicBody2D

const FORCE = 25000
const FORCE_RANGE = 700
const MAX_FORCE = 1000

onready var players = $"/root/Game/Players"

export var charge = 1

func _physics_process(delta):
	for player in players.get_children():
		if player.pause: break
		if position.distance_to(player.position) > FORCE_RANGE: continue
		
		var force = (position - player.position) / position.distance_squared_to(player.position) * FORCE * charge * player.charge
		if force.length() > MAX_FORCE: force = force.normalized() * MAX_FORCE
		if player.survival: force /= 4
		player.velocity -= force