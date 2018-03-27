extends Node2D

var texture = load("res://Nodes/Electrofield.tscn")

func _ready():
	pass

func _process(delta):
	update()

func _draw():
	draw_texture_rect_region()