extends Label

export var player = 0

func _ready():
	var color = Com.PLAYER_COLORS[player]
	add_color_override("font_color", color)
	add_color_override("font_color_shadow", Color(color.r/2, color.g/2, color.b/2))