extends KinematicBody2D

const FORCE = 500

onready var player = get_node("../Ship")

export var charge = 1

func _ready():
	pass

func _physics_process(delta):
	player.velocity -= (position - player.position) / position.distance_squared_to(player.position) * FORCE * charge * player.charge