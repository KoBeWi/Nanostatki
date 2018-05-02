extends Node2D

onready var camera_target = $Camera.position

var choice setget move_selection

func _ready():
	self.choice = 1
	Jukebox.play_music("IDY")

func _process(delta):
	if Input.is_action_just_pressed("ui_right") and choice < 3:
		self.choice += 1
	elif Input.is_action_just_pressed("ui_left") and choice > 0:
		self.choice -= 1
	
	if Input.is_action_just_pressed("ui_accept"):
		match choice:
			1:
				camera_target = Vector2(1082, 987)
			3:
				camera_target.x = 1024
				yield(get_tree().create_timer(1), "timeout")
				get_tree().quit()
	
	$Camera.position += (camera_target - $Camera.position).normalized()
	if $Camera.position.distance_squared_to(camera_target) < 1: $Camera.position = camera_target

func move_selection(new_choice):
	choice = new_choice
	
	for i in range(4):
		var menu = $Title/Nodes.get_child(i)
		if i == choice:
			var color = menu.get_node("Fill/Icon").self_modulate
			menu.get_node("Fill").self_modulate = color
			menu.self_modulate = color
			menu.get_node("Fill/Icon").self_modulate = Color(color.r * 2, color.g * 2, color.b * 2)
		else:
			if menu.self_modulate != Color(1, 1, 1):
				menu.get_node("Fill/Icon").self_modulate = menu.self_modulate
				menu.get_node("Fill").self_modulate = Color(1, 1, 1)
				menu.self_modulate = Color(1, 1, 1)