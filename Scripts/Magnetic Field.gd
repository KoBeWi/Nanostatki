tool
extends Area2D

var TEXTURES = [load("res://Sprites/Common/MagnetDot.png"), load("res://Sprites/Common/MagnetCross.png"), load("res://Sprites/Common/MagnetArrow.png"), load("res://Sprites/Common/MagnetArrow2.png")]

const FORCE = PI/40
const DDIST = 50
enum DIRECTION {OUT, IN}

export var width = 32 setget set_width
export var height = 32 setget set_height

export(DIRECTION) var orientation = 0

var players_in = []

func _physics_process(delta):
	if !Engine.editor_hint:
		for player in players_in:
			player.velocity = player.velocity.rotated(FORCE * player.charge * -(orientation * 2 - 1))
	#		player.direction = player.direction.rotated(FORCE * player.charge * (orientation * 2 - 1))
	
	update()

func _draw():
	var color = Color(1, 1, 1, abs(sin(OS.get_ticks_msec() / 250.0)) + 0.5)
	
	for x in range(int(width / DDIST) + 2):
		for y in range(int(height / DDIST) + 2):
#			draw_texture(TEXTURES[orientation], Vector2(-DDIST/2 - width/2 + x * DDIST, -DDIST/2 - height/2 + y * DDIST), color)
			
			if !(x % 4 == 0 and y % 2 == 0) and !(x % 4 == 2 and y % 2 == 1): continue
			draw_set_transform(Vector2(-DDIST/2 - width/2 + x * DDIST, -DDIST/2 - height/2 + y * DDIST), OS.get_ticks_msec() / 250.0 * -(orientation * 2 - 1), Vector2(1, 1))
			draw_texture(TEXTURES[2 + orientation], Vector2(-32, -32), color)
			draw_set_transform(Vector2(), 0, Vector2(1, 1))

func set_width(neww):
	width = neww
	if has_node("Shape"):
		$Shape.shape.extents.x = neww/2

func set_height(newh):
	height = newh
	if has_node("Shape"):
		$Shape.shape.extents.y = newh/2

func _on_enter(body):
	if body.is_in_group("players"):
		players_in.append(body)

func _on_exit(body):
	if body.is_in_group("players"):
		players_in.erase(body)