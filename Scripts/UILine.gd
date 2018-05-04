tool
extends Sprite

export(NodePath) var start = NodePath() setget set_start
export(NodePath) var end = NodePath() setget set_end

func _process(delta):
	update_start_end()

func set_start(_start):
	start = _start
	update_start_end()

func set_end(_end):
	end = _end
	update_start_end()

func update_start_end():
	if has_node(start) and has_node(end):
		var _start = get_node(start)
		var _end = get_node(end)
		var dir = (_end.global_position - _start.global_position).normalized()
		
		var start_pos = _start.global_position + dir * (_start.texture.get_width()/2-12 if _start.get("texture") else 0)
		var end_pos = _end.global_position - dir * (_end.texture.get_width()/2-12 if _end.get("texture") else 0)
		
		rotation = dir.angle()
		global_position = (start_pos + end_pos)/2
		region_rect.size.x = (start_pos - end_pos).length()