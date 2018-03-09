extends Node

var pressed = {}
var pressing = {}
var released = {}

func _process(delta):
	for key in pressed.keys():
		pressing[key] = true
	
	pressed.clear()
	released.clear()
	
	for key in pressing.keys():
		if !Input.is_key_pressed(key):
			released[key] = true
	
	for key in released.keys():
		if pressing.has(key): pressing.erase(key)

func key_hold(key):
	return Input.is_key_pressed(key)

func key_press(key):
	if !pressing.has(key) and Input.is_key_pressed(key):
		pressed[key] = true
		return true
	
	return false

func key_release(key):
	return released.has(key)