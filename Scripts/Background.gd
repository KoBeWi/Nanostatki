extends Sprite

const FIG_COUNT = 10
const SWATCHES = [
[Color("368fdc"), Color("1d1f65"), Color("3da4ff"), Color("1d2469")],
[Color("ff4161"), Color("590d19"), Color("d92d49"), Color("771121")],
[Color("00e75d"), Color("004a1e"), Color("809e00"), Color("3a4700")]
]
const FIGURES = ["Square", "Triangle"]
var FIGURE = load("res://Nodes/BackgroundBit.tscn")

onready var camera = $"/root/Game/Camera"

var figure
var swatches

func _ready():
	figure = load("res://Sprites/Common/BackgroundBits/" + FIGURES[randi() % FIGURES.size()] + ".png")
	swatches = SWATCHES[randi() % SWATCHES.size()]
	set_colors(vec(swatches[0]), vec(swatches[1]))

func set_colors(upper_color, lower_color):
	material.set_shader_param("upper_color", upper_color)
	material.set_shader_param("lower_color", lower_color)

func set_texture_size(width, height):
	texture.size = Vector2(width, height)

func _physics_process(delta):
	if get_child_count() < FIG_COUNT:
		var fig = FIGURE.instance()
		fig.camera = camera
		fig.texture = figure
		fig.set_colors(vec(swatches[2]), vec(swatches[3]))
		
		var angle = randf() * PI * 2
		fig.position = camera.position + Vector2(cos(angle), -sin(angle)) * 1024 * camera.zoom.x
		fig.angle = angle
		add_child(fig)

func vec(color):
	return Vector3(color.r, color.g, color.b)