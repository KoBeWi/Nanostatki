extends ColorRect

const FIG_COUNT = 50
const SWATCHES = [
[Color("368fdc"), Color("1d1f65"), Color("3da4ff"), Color("1d2469")],
[Color("ff4161"), Color("590d19"), Color("d92d49"), Color("771121")],
[Color("1f0838"), Color("7421c7"), Color("1f0838"), Color("7421c7")],
[Color("0e350c"), Color("25ac28"), Color("0e350c"), Color("25ac28")],
[Color("e75900"), Color("ffa100"), Color("e75900"), Color("ffa100")],
[Color("074f59"), Color("43c1b5"), Color("074f59"), Color("43c1b5")],
[Color("1a2844"), Color("1e66cb"), Color("1a2844"), Color("1e66cb")]
]
const FIGURES = ["Square", "Triangle", "Diamond", "Pentagon", "Rectangle", "StraightSquare", "TiltedTriangle", "WideTriangle"]
var FIGURE = load("res://Nodes/BackgroundBit.tscn")

var camera

var figure_count = FIG_COUNT
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
	
	for i in range(figure_count):
		create_figure(false)

func _physics_process(delta):
	if get_child_count() < figure_count:
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
	fig.angle = angle
	
	fig.position = Vector2(randi() % int(rect_size.x), randi() % int(rect_size.y))
	var check = Vector2()
	var check2 = Vector2(1 ,1)
	if camera:
		check = camera.global_position
		check2 = camera.zoom
	if rect_size.x > 1024:
		var i = 0
		while check_camera and fig.global_position.distance_to(check) < 1536 * check2.x:
			fig.position = Vector2(randi() % int(rect_size.x), randi() % int(rect_size.y))
			i += 1
			if i >= 1000: break