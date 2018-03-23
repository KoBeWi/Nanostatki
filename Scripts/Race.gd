extends Node2D

func _ready():
	var background = $"Track/Background".texture
	$"../Camera".limit_left = -background.get_width()/2
	$"../Camera".limit_right = background.get_width()/2
	$"../Camera".limit_top = -background.get_height()/2
	$"../Camera".limit_bottom = background.get_height()/2