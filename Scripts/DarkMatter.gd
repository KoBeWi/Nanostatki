extends Area2D

func _process(delta):
	update()

func _draw():
	pass

func _on_enter(body):
	if body.is_in_group("players"):
		body.paralyzed = true
		yield(get_tree().create_timer(1), "timeout")
		body.paralyzed = false