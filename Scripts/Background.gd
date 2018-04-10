extends Sprite

const SQ_COUNT = 10

onready var camera = $"/root/Game/Camera"
var square = load("res://Nodes/Backgrounds/Particles/Square.tscn")

func set_colors(upper_color, lower_color):
	material.set_shader_param("upper_color", upper_color / 255.0)
	material.set_shader_param("lower_color", lower_color / 255.0)

func set_texture_size(width, height):
	texture.size = Vector2(width, height)

func _physics_process(delta):
	if get_child_count() < SQ_COUNT:
		var sq = square.instance()
		var angle = randf() * PI * 2
		sq.position = camera.position + Vector2(cos(angle), -sin(angle)) * 1024 * camera.zoom.x
		sq.angle = angle
		sq.camera = camera
		add_child(sq)