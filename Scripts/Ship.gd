extends KinematicBody2D

const ACCELERATION = 100
const DAMP = 0.1
const ROT_SPEED = -PI/60
const FORCE = 25000
const FORCE_RANGE = 750

var SPARKLE = load("res://Nodes/Effects/HitParticle.tscn")

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
	$Sprite/Indicator.modulate = Com.PLAYER_COLORS[team]

func _physics_process(delta):
	if pause:
		$Engine.stop()
		return
	var move = false
	
	if !drag_race and !paralyzed:
		if Input.is_action_pressed(action("forward")): move = true
		if Input.is_action_pressed(action("left")): direction = direction.rotated(ROT_SPEED)
		if Input.is_action_pressed(action("right")): direction = direction.rotated(-ROT_SPEED)
	
	if move: velocity += direction.normalized() * ACCELERATION
	rotation = direction.angle()
	
	if !paralyzed and Input.is_action_just_pressed(action("action")): swap_charge()
	
	if drag_race:
		if !paralyzed and velocity.y > -70: velocity.y -= 40
		velocity.y *= 1 - DAMP / 100
		if velocity.length() > 5000: velocity *= DAMP * 9
	else:
		velocity *= 1-DAMP
		if velocity.length() > 2000: velocity *= DAMP * 8
	
	if move and !$Engine.playing:
		$Engine.play()
	elif !move:
		$Engine.stop()
	
	move_and_slide(velocity)
	
	if get_slide_count() > 0:
		
		if velocity.length() > 800:
			Com.play_sample(self, "Tap")
			
			for i in range(get_slide_count()):
				var col = get_slide_collision(i)
				var spark = SPARKLE.instance()
				spark.position = col.position
				spark.rotation = col.normal.angle()
				$"/root/Game".add_child(spark)
#		if velocity.length() > 800:
#			Com.play_sample(self, "Clang")
#		elif velocity.length() > 400:
#			Com.play_sample(self, "Tap")

	if !drag_race: for player in get_parent().get_children():
		if player != self and position.distance_to(player.position) < FORCE_RANGE:
			var force = (position - player.position) / position.distance_squared_to(player.position) * FORCE * charge * player.charge
			player.velocity -= force

func swap_charge():
	charge = -charge
	$Sprite/Orb.modulate = (Color(0, 0, 0) if charge < 0 else Color(1, 1, 1))

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
	$Sprite/Orb.modulate.a = 0.5 if value else 1