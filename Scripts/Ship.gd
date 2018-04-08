extends KinematicBody2D

const ACCELERATION = 100
const DAMP = 0.1
const ROT_SPEED = -PI/60
const FORCE = 25000
const FORCE_RANGE = 400

export var team = 0
export var player = 0

var pause = false
var paralyzed = false setget set_paralyzed
var race_distance = 0
var race_leader = false
var drag_race = false
var survival = false

var velocity = Vector2()
var direction = Vector2(1, 0)
var charge = 1

func _ready():
	$Indicator.modulate = Com.PLAYER_COLORS[team]

func _physics_process(delta):
	if pause: return
	var move = false
	
	if !drag_race and !paralyzed:
		if Input.is_action_pressed(action("forward")): move = true
		if Input.is_action_pressed(action("left")): direction = direction.rotated(ROT_SPEED)
		if Input.is_action_pressed(action("right")): direction = direction.rotated(-ROT_SPEED)
	
	if move: velocity += direction.normalized() * ACCELERATION
	velocity += -velocity * DAMP
	rotation = direction.angle()
	
	if !paralyzed and Input.is_action_just_pressed(action("action")): swap_charge()
	
	move_and_slide(velocity)

	for player in get_parent().get_children():
		if player != self and position.distance_to(player.position) < FORCE_RANGE:
			var force = (position - player.position) / position.distance_squared_to(player.position) * FORCE * charge * player.charge
			player.velocity -= force

func swap_charge():
	charge = -charge
	$Sprite.frame = 1 - (charge + 1)/2

func action(action):
	return "p" + str(player+1) + "_" + action

func change_floor(i):
	z_index = i+5
	collision_layer = i+1
	collision_mask = i+1

func ahead():
	return position + direction * velocity.length() / 2

func get_pos():
	if race_leader:
		return position + direction * velocity.length() / 2
	else:
		return position

func set_paralyzed(value):
	paralyzed = value
	$Indicator.modulate.a = 0.5 if value else 1