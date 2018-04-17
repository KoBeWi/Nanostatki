tool
extends KinematicBody2D

const FORCE = 25000
const FORCE_RANGE = 700
const MAX_FORCE = 1000

onready var players = $"/root/Game/Players"

export var charge = 1

func _physics_process(delta):
	if !Engine.editor_hint:
		for player in players.get_children():
			if player.pause: break
			if position.distance_to(player.position) > FORCE_RANGE: continue
			
			var force = (position - player.position) / position.distance_squared_to(player.position) * FORCE * charge * player.charge
			if force.length() > MAX_FORCE: force = force.normalized() * MAX_FORCE
			if player.survival: force /= 4
			player.velocity -= force
			
#			if player.pause: break
#			var d = position.distance_to(player.position)
#			if d > FORCE_RANGE or d == 0: continue
#
#			var dist = (position - player.position)
#
#			var force = Vector2()
#			if !player.drag_race:
#				force = dist / dist.length() / 150 * FORCE * charge * player.charge
#			elif abs(dist.y) > 50:
#				force.y = sign(dist.y) / sqrt(abs(dist.y)) / 50 * FORCE * charge * player.charge
#			else: force.y = sign(dist.y) / sqrt(50) / 50 * FORCE * charge * player.charge
#			if force.length() > MAX_FORCE: force = force.normalized() * MAX_FORCE
#			if player.survival: force /= 4
#			player.velocity -= force
	
	update()

func _draw():
	if Engine.editor_hint:
		draw_circle(Vector2(), FORCE_RANGE, Color(1, 1, 1, 0.1))
		return
	
	if players.get_child(0).drag_race and position.y < $"/root/Game/Camera".position.y - 512:
		$"../..".self_modulate = [Color(0, 0, 1), Color(1, 0, 0)][(charge + 1)/2]
#		draw_texture($Sprite.texture, Vector2(-32, $"/root/Game/Camera".position.y - position.y - 332))