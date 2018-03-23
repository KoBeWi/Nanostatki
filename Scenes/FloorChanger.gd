extends Node2D

func _ready():
	pass

func _on_up_enter(body):
	body.change_floor(1)

func _on_down_enter(body):
	body.change_floor(0)