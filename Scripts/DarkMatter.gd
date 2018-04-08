extends Area2D

var fx = load("res://Sprites/Common/DarknessFX.png")

var counter = 0

func _process(delta):
	counter += 1
	
	if counter%8 == 0: update()

func _draw():
	for i in range(3):
		if randi() % 100 < 50: continue
		
		var angle = randf() * PI * 2
		draw_set_transform_matrix(Transform2D().translated(Vector2(-32, -40)).rotated(angle))
		draw_texture(fx, Vector2())

func _on_enter(body):
	if body.is_in_group("players"):
		body.paralyzed = true
		yield(get_tree().create_timer(1), "timeout")
		body.paralyzed = false