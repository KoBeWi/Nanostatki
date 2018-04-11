extends Sprite

const TIMEOUT = 2.0
var timeout = TIMEOUT

var angle = 0
var rotating = -0.05 + randf() * 0.1
var speed = randf() * 2
var camera

func _ready():
	rotation_degrees = randi()%360
	var sc = 0.5 + randf()*0.5
	scale = Vector2(sc, sc)

func _physics_process(delta):
	timeout -= delta
	position -= Vector2(cos(angle), -sin(angle)) * speed
	rotation += rotating
	
	if position.distance_to(camera.position) > 1024 * camera.zoom.x:
		queue_free()

func set_colors(upper_color, lower_color):
	material.set_shader_param("upper_color", upper_color)
	material.set_shader_param("lower_color", lower_color)