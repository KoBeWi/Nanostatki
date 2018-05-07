extends Sprite

var IMPULSE = preload("res://Nodes/Effects/MenuImpulse.tscn")
onready var start_pos = self.position

var off_balance
var connected = {}

func _process(delta):
	if off_balance:
		position = start_pos + off_balance
		off_balance /= 1.1
		if off_balance.length_squared() < 1: off_balance = null
	
	position += Vector2(-1 + randf()*2, -1 + randf()*2) * 0.2
	
	if (position - start_pos).length_squared() > 256: position = start_pos + (position - start_pos)/2

func impulse(from):
	off_balance = (position - from.position)/10
	$"/root/MainMenu/Samples/Move".play()
	if from.connected.has(self):
		var line = from.connected[self][0]
		var start = from.connected[self][1]
		var impulse = IMPULSE.instance()
		from.add_child(impulse)
		impulse.goto(line.start_pos if start else line.end_pos, line.end_pos if start else line.start_pos)