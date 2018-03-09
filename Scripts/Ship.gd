extends KinematicBody2D
onready var Com = get_node("/root/Commons")

const ACCELERATION = 6
const DAMP = 0.4
const THRESHOLD = 0.5

var velocity = Vector2()
var direction = Vector2(1, 0)
var charge = 1

func _ready():
	pass

func _physics_process(delta):
	var move = false
	
	if Com.key_hold(KEY_UP): move = true
#	if Com.key_hold(KEY_DOWN): move.y = 1
	if Com.key_hold(KEY_LEFT): direction = direction.rotated(-PI/20)
	if Com.key_hold(KEY_RIGHT): direction = direction.rotated(PI/20)
	
	if move: velocity += direction.normalized() * ACCELERATION
	rotation = direction.angle()
	
	if Com.key_press(KEY_SPACE):
		swap_charge()
	
	move_and_collide(velocity)
	velocity *= DAMP
	if velocity.length() < THRESHOLD: velocity = Vector2()

func swap_charge():
	charge = -charge
	$Sprite.frame = 1 - (charge + 1)/2