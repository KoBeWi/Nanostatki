extends KinematicBody2D
onready var Com = get_node("/root/Commons")
onready var players = $"..".get_children()

const ACCELERATION = 100
const DAMP = 0.1
const ROT_SPEED = -PI/60
const FORCE = 25000
const MIN_FORCE = 5

export var player = 0

var velocity = Vector2()
var direction = Vector2(1, 0)
var charge = 1

func _ready():
	$Indicator.modulate = [Color(1, 1, 0), Color(0, 1, 0), Color(0, 1, 1), Color(1, 0, 1)][player]

func _physics_process(delta):
	var move = false
	
	if Com.key_hold("up", player): move = true
	if Com.key_hold("left", player): direction = direction.rotated(ROT_SPEED)
	if Com.key_hold("right", player): direction = direction.rotated(-ROT_SPEED)
	
	if move: velocity += direction.normalized() * ACCELERATION
	velocity += -velocity * DAMP
	rotation = direction.angle()
	
	if Com.key_press("swap", player):
		swap_charge()
	
	move_and_slide(velocity)

	for player in players:
		if player != self:
			var force = (position - player.position) / position.distance_squared_to(player.position) * FORCE * charge * player.charge
			if force.length() > MIN_FORCE: player.velocity -= force

func swap_charge():
	charge = -charge
	$Sprite.frame = 1 - (charge + 1)/2

func change_floor(i):
	z_index = i+5