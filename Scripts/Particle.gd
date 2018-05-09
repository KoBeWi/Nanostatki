tool
extends StaticBody2D

const FORCE = 25000
const FORCE_RANGE = 700
const MAX_FORCE = 1000

onready var players = $"/root/Game/Players"

export var charge = 1

var drag_track
var circles = []
var circle_delay = 0

func _physics_process(delta):
	if !Engine.editor_hint:
		for player in players.get_children():
			if player.pause: break
			var d = position.distance_to(player.position)
			if d > FORCE_RANGE or d == 0: continue
			
			var dist = (position - player.position)
			
			var force = Vector2()
			
			if !player.drag_race:
				force = dist / dist.length() / sqrt(dist.length()) / 20 * FORCE * charge * player.charge
			elif abs(dist.y) > 100:
				force.y = sign(dist.y) / sqrt(abs(dist.y)) / 50 * FORCE * charge * player.charge
			else: force.y = sign(dist.y) / sqrt(50) / 50 * FORCE * charge * player.charge
			
			if force.length() > MAX_FORCE: force = force.normalized() * MAX_FORCE
			if player.survival: force /= 4
			player.velocity -= force
	
	if !drag_track:
		if circle_delay <= 0:
			circles.append(0)
			circle_delay = 1
		else:
			circle_delay -= delta
	
	update()

func _draw():
	if Engine.editor_hint:
		draw_circle(Vector2(), FORCE_RANGE, Color(1, 1, 1, 0.1))
	elif !drag_track:
		var trash = []
		
		for i in range(circles.size()):
			circles[i] += FORCE_RANGE/120
			if circles[i] >= FORCE_RANGE: trash.append(circles[i])
			
			var color = $Orb.modulate
			color.a = 0.5 - 0.5 * circles[i] / FORCE_RANGE
			if charge == -1: color.a = 0.5 - color.a
			draw_circle(Vector2(), circles[i] if charge == 1 else FORCE_RANGE - circles[i], color)
		
		for i in trash: circles.erase(i)
	
#	if players.get_child(0).drag_race and position.y < $"/root/Game/Camera".position.y - 512:
#		$"../..".self_modulate = [Color(0, 0, 1), Color(1, 0, 0)][(charge + 1)/2]
#		draw_texture($Sprite.texture, Vector2(-32, $"/root/Game/Camera".position.y - position.y - 332))