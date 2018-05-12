extends Sprite

var angle = 0
var rotating = -0.01 + randf() * 0.02
var speed = randf()/2
var camera

func _ready():
	rotation_degrees = randi()%360
	var sc = 0.5 + randf()*0.5
	scale = Vector2(sc, sc)

func _physics_process(delta):
	position -= Vector2(cos(angle), -sin(angle)) * speed
	rotation += rotating
	
	if camera and camera.get_ref() and global_position.distance_to(camera.get_ref().global_position) > 2048 * camera.zoom.x or (!camera or !camera.get_ref()) and position.length() > 2048:
		queue_free()

func set_colors(upper_color, lower_color):
	material.set_shader_param("upper_color", upper_color)
	material.set_shader_param("lower_color", lower_color)