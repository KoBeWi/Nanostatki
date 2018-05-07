tool
extends Sprite

export(NodePath) var start = NodePath() setget set_start
export(NodePath) var end = NodePath() setget set_end

var start_pos
var end_pos

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
		if !Engine.editor_hint:
			if _start.has_method("impulse"): _start.connected[_end] = [self, true]
			if _end.has_method("impulse"): _end.connected[_start] = [self, false]
		var dir = (_end.global_position - _start.global_position).normalized()
		
		start_pos = _start.global_position + dir * (_start.texture.get_width()/2-12 if _start.get("texture") else 0)
		end_pos = _end.global_position - dir * (_end.texture.get_width()/2-12 if _end.get("texture") else 0)
		
		rotation = dir.angle()
		global_position = (start_pos + end_pos)/2
		region_rect.size.x = (start_pos - end_pos).length()