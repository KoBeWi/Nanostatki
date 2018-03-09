extends Area2D

onready var texture = load("res://Sprites/Magnet.png")
onready var size = $Field.shape.extents*2
onready var player = get_node("../Ship")

const FORCE = 500
const DDIST = 25


#export var charge = 1
var player_in = false

func _ready():
	pass

func _physics_process(delta):
	if player_in:
		player.direction = player.direction.rotated(PI/50)
	
	update()

func _draw():
	var cols = size.x / DDIST
	var rows = size.y / DDIST
	
	var color = Color(1, 1, 1, abs(sin(OS.get_ticks_msec() / 500.0)) + 0.5)
	for x in range(cols):
		for y in range(rows):
			draw_texture(texture, Vector2(DDIST/2 - size.x/2 + x * DDIST, DDIST/2 - size.y/2 + y * DDIST), color)

func _on_enter(body):
	if body == player: player_in = true

func _on_exit(body):
	if body == player: player_in = false