extends Node

const PLAYER_COLORS = [Color(1, 1, 0), Color(0, 1, 0), Color(0, 1, 1), Color(1, 0, 1)]

func load_nodenames():
	return [load("res://Sprites/UI/ModenameRace.png"), load("res://Sprites/UI/ModenameDrag.png"), load("res://Sprites/UI/ModenameSumo.png"), load("res://Sprites/UI/ModenameArena.png"), load("res://Sprites/UI/ModenameSurvival.png")]

func load_videos():
	return [load("res://Resources/Video/Video1.ogm"), null, load("res://Resources/Video/Video3.webm"), null, null]