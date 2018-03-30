extends Node2D

const FORCE = 50
enum DIRECTION {NORTH, EAST, SOUTH, WEST}
const FORCE_V = {NORTH: Vector2(0, -1), EAST: Vector2(1, 0), SOUTH: Vector2(0, 1), WEST: Vector2(-1, 0)}

export(DIRECTION) var direction = NORTH

var texture = load("res://Sprites/Common/Electrofield.png")

var offset = 0
var players_in = []

onready var size = $Field.shape.extents * 2
onready var tex_w = texture.get_width()
onready var tex_h = texture.get_height()
onready var fixed_h = tex_h / 2
onready var x = -size.x/2 - tex_w/2
onready var y = -size.y/2 - fixed_h/2

func _physics_process(delta):
	for player in players_in:
		player.velocity += FORCE_V[direction] * FORCE
	
	offset += delta * 100
	update()

func _draw():
	
	var frame = OS.get_ticks_msec() / 100 % 8
	for dx in range(size.x / tex_w + 2):
		for dy in range(size.y / fixed_h + 2):
			match direction:
				EAST: draw_texture_rect_region(texture, Rect2(x + dx * tex_w, y + dy * fixed_h, tex_w, tex_h/8), Rect2(0, tex_h/8 * frame, tex_w, tex_h/8))
				WEST: draw_texture_rect_region(texture, Rect2(x + dx * tex_w, y + dy * fixed_h, tex_w, tex_h/8), Rect2(0, tex_h/8 * frame, -tex_w, tex_h/8))
				NORTH: draw_texture_rect_region(texture, Rect2(x + dx * tex_w, y + dy * fixed_h, tex_w, tex_h/8), Rect2(0, tex_h/8 * frame, tex_w, -tex_h/8), Color(1, 1, 1), true)
				SOUTH: draw_texture_rect_region(texture, Rect2(x + dx * tex_w, y + dy * fixed_h, tex_w, tex_h/8), Rect2(0, tex_h/8 * frame, tex_w, tex_h/8), Color(1, 1, 1), true)

func _on_enter(body):
	if body.is_in_group("players"):
		players_in.append(body)

func _on_exit(body):
	if body.is_in_group("players"):
		players_in.erase(body)