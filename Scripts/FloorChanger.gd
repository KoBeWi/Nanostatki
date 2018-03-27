extends Node2D

func _on_up_enter(body):
	if body.is_in_group("players"):
		body.change_floor(1)

func _on_down_enter(body):
	if body.is_in_group("players"):
		body.change_floor(0)