extends Node

const PLAYER_COLORS = [Color(1, 1, 0), Color(0, 1, 0), Color(0, 1, 1), Color(1, 0, 1)]

var race_backgrounds = [load("res://Sprites/Race/Background1.png"), load("res://Sprites/Race/Background2.png")]

##wszystko na dole jest niepotrzebne :/

var pressed = {}
var pressing = {}
var released = {}

var controls1 = {"up": KEY_UP, "down": KEY_DOWN, "right": KEY_RIGHT, "left": KEY_LEFT, "swap": KEY_ENTER}
var controls2 = {"up": KEY_W, "down": KEY_S, "right": KEY_D, "left": KEY_A, "swap": KEY_CONTROL}
var controls3 = {"up": KEY_I, "down": KEY_K, "right": KEY_L, "left": KEY_J, "swap": KEY_SPACE}
var controls4 = {"up": KEY_KP_8, "down": KEY_KP_2, "right": KEY_KP_6, "left": KEY_KP_4, "swap": KEY_KP_5}

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

func key_hold(key, player):
	return Input.is_key_pressed(get_key(key, player))

func key_press(key, player):
	if !pressing.has(get_key(key, player)) and Input.is_key_pressed(get_key(key, player)):
		pressed[get_key(key, player)] = true
		return true
	
	return false

func key_release(key, player):
	return released.has(get_key(key, player))

func get_key(key, player):
	return [controls1, controls2, controls3, controls4][player][key]