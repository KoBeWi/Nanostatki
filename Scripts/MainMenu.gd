extends Node2D

var choice setget move_selection

func _ready():
	self.choice = 1

func _process(delta):
	if Input.is_action_just_pressed("ui_right") and choice < 3:
		self.choice += 1
	elif Input.is_action_just_pressed("ui_left") and choice > 0:
		self.choice -= 1

func move_selection(new_choice):
	choice = new_choice
	
	for i in range(4):
		var menu = $CanvasLayer.get_child(i)
		if i == choice:
			menu.self_modulate = menu.get_node("Fill/Icon").self_modulate
		else:
			menu.self_modulate = Color(1, 1, 1)
