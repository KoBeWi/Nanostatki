tool
extends Sprite

var last_position

func _ready():
	$Effector/Shape.shape = RectangleShape2D.new()
	move_end()
	last_position = $End.position

func _process(delta):
#	$Sprite.region_rect.position.x += 1
	
	if has_node("End") and $End.position != last_position:
		move_end()
		last_position = $End.position

func _on_enter(body):
	if body.is_in_group("players"):
		body.paralyzed = true
		yield(get_tree().create_timer(1), "timeout")
		body.paralyzed = false

func move_end():
	$Sprite.position = $End.position/2
	$Sprite.rotation = $End.position.angle()
#	$Sprite.region_rect.size.x = $End.position.length()
	$Sprite.scale.x = $End.position.length() / 1280
	
	$Effector.position = $End.position/2
	$Effector.rotation = $End.position.angle()
	$Effector/Shape.shape.extents.x = $End.position.length()/2