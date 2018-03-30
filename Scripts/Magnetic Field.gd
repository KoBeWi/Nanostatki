extends Area2D

onready var tex1 = load("res://Sprites/Common/MagnetDot.png")
onready var tex2 = load("res://Sprites/Common/MagnetCross.png")

const FORCE = PI/40
const DDIST = 50

onready var size = $Field.shape.extents * 2
onready var cols = int(size.x / DDIST) + 2
onready var rows = int(size.y / DDIST) + 2

export var charge = 1

var players_in = []

func _physics_process(delta):
	for player in players_in:
		player.velocity = player.velocity.rotated(FORCE * player.charge * charge)
		#player.direction = player.direction.rotated(PI/50)
	
	update()

func _draw():
	var color = Color(1, 1, 1, abs(sin(OS.get_ticks_msec() / 250.0)) + 0.5)
	var texture = [tex1, tex2][(2 - charge)/2]
	for x in range(cols):
		for y in range(rows):
			draw_texture(texture, Vector2(-DDIST/2 - size.x/2 + x * DDIST, -DDIST/2 - size.y/2 + y * DDIST), color)

func _on_enter(body):
	if body.is_in_group("players"):
		players_in.append(body)

func _on_exit(body):
	if body.is_in_group("players"):
		players_in.erase(body)