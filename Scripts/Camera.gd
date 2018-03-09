extends Camera2D

onready var player = get_node("../Ship")

func _process(delta):
	position = player.position