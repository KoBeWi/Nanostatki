extends ColorRect

const FIG_COUNT = 50
const SWATCHES = [
[Color("368fdc"), Color("1d1f65"), Color("3da4ff"), Color("1d2469")],
[Color("ff4161"), Color("590d19"), Color("d92d49"), Color("771121")],
[Color("00e75d"), Color("004a1e"), Color("809e00"), Color("3a4700")],
[Color("ff420e"), Color("80bd9e"), Color("ff420e"), Color("80bd9e")],
[Color("00cfff"), Color("e2ff00"), Color("00cfff"), Color("e2ff00")],
[Color("e33c00"), Color("d8e313"), Color("e33c00"), Color("d8e313")],
[Color("122275"), Color("1eb2d9"), Color("122275"), Color("1eb2d9")],
[Color("d72878"), Color("0bf505"), Color("d72878"), Color("0bf505")],
[Color("fa709a"), Color("fee140"), Color("fa709a"), Color("fee140")],
[Color("13547a"), Color("80d0c7"), Color("13547a"), Color("80d0c7")]
]
const FIGURES = ["Square", "Triangle", "Diamond", "Pentagon", "Rectangle", "StraightSquare", "TiltedTriangle", "WideTriangle"]
var FIGURE = load("res://Nodes/BackgroundBit.tscn")

var camera

var figure
var swatches

func _ready():
	figure = load("res://Sprites/Common/BackgroundBits/" + FIGURES[randi() % FIGURES.size()] + ".png")
	swatches = SWATCHES[randi() % SWATCHES.size()]
	set_colors(vec(swatches[0]), vec(swatches[1]))
	
	if $"/root".has_node("Game/Camera"): camera = $"/root/Game/Camera"

func set_colors(upper_color, lower_color):
	material.set_shader_param("upper_color", upper_color)
	material.set_shader_param("lower_color", lower_color)

func set_texture_size(width, height):
	rect_position = Vector2(-width/2, -height/2)
	rect_size = Vector2(width, height)
	
	for i in range(FIG_COUNT):
		create_figure(false)

func _physics_process(delta):
	if get_child_count() < FIG_COUNT:
		create_figure()

func vec(color):
	return Vector3(color.r, color.g, color.b)

func create_figure(check_camera = true):
	var fig = FIGURE.instance()
	add_child(fig)
	
	fig.camera = camera
	fig.texture = figure
	fig.set_colors(vec(swatches[2]), vec(swatches[3]))
	
	var angle = randf() * PI * 2
	fig.position = Vector2(randi() % int(rect_size.x), randi() % int(rect_size.y))
	while check_camera and fig.global_position.distance_to(camera.global_position) < 1536 * camera.zoom.x: fig.position = Vector2(randi() % int(rect_size.x), randi() % int(rect_size.y))
	fig.angle = angle
	