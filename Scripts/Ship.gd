extends KinematicBody2D

const ACCELERATION = 100
const DAMP = 0.1
const ROT_SPEED = -PI/60
const FORCE = 25000
const FORCE_RANGE = 750

export var team = 0
export var player = 0

var pause = false
var paralyzed = false setget set_paralyzed
var race_distance = 0
var race_leader = false
var drag_race = false
var survival = false
var time = 0

var velocity = Vector2()
var direction = Vector2(1, 0)
var charge = 1

var last_emitter = 0
var last_collision = 0
var clang
var swap = 0
var fade_out
var exploding
var camera

signal faded
signal exploded

func _ready():
	$Sprite/Indicator.modulate = Com.PLAYER_COLORS[team]

func _physics_process(delta):
	time += 1
	
	if fade_out:
		modulate.a -= delta
		if modulate.a <= 0:
			fade_out = false
			emit_signal("faded")
	
	if exploding:
		if exploding < 1.4: material.set_shader_param("whiteness", abs(OS.get_ticks_msec() * 100 % 2000 - 1000) / 1000.0)
		exploding += delta
		
		if exploding >= 1 and exploding < 1.4:
			$Survival/Indicator.visible = false
			$Explosion.visible = true
			$Explosion.scale -= Vector2(delta, delta) * 10
			$Explosion.rotation += PI * delta * 10
		elif exploding >= 1.5 and exploding <= 3:
			survival.visible = true
			survival.color.a = 0.9 - (exploding - 1.5) / 1.5 * 0.9
		
		if exploding >= 3.5:
			survival.visible = false
			queue_free()
			emit_signal("exploded")
	
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
		#if !paralyzed and velocity.y > -70: velocity.y -= 40
		if (velocity.y < -5):
			velocity.y += 5
			if Com.easy_mode == true: velocity.y -=2
		if Com.easy_mode == true:
			velocity.y *= 1 - DAMP / 80
		else:
			velocity.y *= 1 - DAMP / 50
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
		for i in range(min($Particles.get_child_count(), get_slide_count())):
			var col = get_slide_collision(i)
			var emitter = $Particles.get_child((i + last_emitter) % $Particles.get_child_count())
			emitter.reset_timer()
			emitter.global_position = col.position
			emitter.rotation = col.normal.angle()
			last_emitter += 1
		
		if velocity.length() > 800:
			if OS.get_ticks_msec() - last_collision > 100:
				clang = Com.play_sample(self, "Clang")
			elif !clang or !clang.get_ref():
				clang = null
#				Com.play_sample(self, "Tap")
		
		last_collision = OS.get_ticks_msec()

	if !drag_race: for player in get_parent().get_children():
		if player != self and position.distance_to(player.position) < FORCE_RANGE:
			var force = (position - player.position) / position.distance_squared_to(player.position) * FORCE * charge * player.charge
			player.velocity -= force
	
	if time % 4 == 0:
		var trace = $Sprite/Orb.duplicate(DUPLICATE_USE_INSTANCING | DUPLICATE_SCRIPTS)
		$"/root/Game".add_child(trace)
		trace.z_index = z_index
		trace.transform = $Sprite/Orb.global_transform
		trace.position += Vector2(-4 + randi() % 9, -4 + randi() % 9)
		trace.vanishing = true
	
	update()

func _draw():
	if swap > 0:
		var rgb = 0 if charge == -1 else 1
		draw_circle(Vector2(), (1 - swap/15.0 if charge == 1 else swap/15.0) * FORCE_RANGE, Color(rgb, rgb, rgb, swap/15.0))
		swap -= 1
	
	if exploding and exploding > 1.4:
		$Sprite.visible = false
		material = null
		draw_circle(Vector2(), min((exploding - 1.4) * 500, 480), Color(1, 1, 1, 1 - max(0, exploding - 2.5)))

func swap_charge():
	charge = -charge
	$Sprite/Orb.modulate = (Color(0, 0, 0.25) if charge < 0 else Color(1, 1, 1))
	Com.play_sample(self, "Swap" + ("Plus" if charge == 1 else "Minus"))
	swap = 15

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
	if value: $EngineDown.play()
	paralyzed = value
	$Sprite/Orb.modulate.a = 0.5 if value else 1

func explode():
	Com.play_sample(self, "Explosion")
	material = load("res://Resources/Explode.tres")
	paralyzed = true
	exploding = 0.000001