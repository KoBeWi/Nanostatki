extends Node2D

func _ready():
	$Sprite.position = $End.position/2
	$Sprite.rotation = $End.position.angle()
	$Sprite.region_rect.size.x = $End.position.length()
	
	$Effector.position = $End.position/2
	$Effector.rotation = $End.position.angle()
	$Effector/Shape.shape.extents.x = $End.position.length()/2

func _process(delta):
	$Sprite.region_rect.position.x += 1

func _on_enter(body):
	if body.is_in_group("players"):
		body.paralyzed = true
		yield(get_tree().create_timer(1), "timeout")
		body.paralyzed = false