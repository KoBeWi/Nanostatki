extends Sprite

onready var start_pos = self.position

var off_balance

func _process(delta):
	if off_balance:
		position = start_pos + off_balance
		off_balance /= 1.1
		if off_balance.length_squared() < 1: off_balance = null
	
	position += Vector2(-1 + randf()*2, -1 + randf()*2) * 0.2
	
	if (position - start_pos).length_squared() > 256: position = start_pos + (position - start_pos)/2