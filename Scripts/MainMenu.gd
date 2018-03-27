extends Node2D

onready var font32 = load("res://Resources/Font32.tres")
onready var font16 = load("res://Resources/Font16.tres")
onready var key = load("res://Sprites/UI/Key.png")

var texture1 = load("res://Sprites/Title.png")
var texture2 = load("res://Sprites/PlayerScreen.png")

enum {MAIN, PLAYERS}
const MODES = ["Race2", "Drag", "Sumo", "Arena", "Survival"]
const MODE_NAMES = {"Race2": "WYŚCIG STANDARDOWY", "Drag": "WYŚCIG RÓWNOLEGŁY", "Sumo": "ARENA SUMO", "Arena": "ARENA PUNKTOWA", "Survival": "PRZETRWANIE"}

var state = MAIN
var select = 0
var mode
var started = false

var players_joined = [-1, -1, -1, -1]
var players_in = [false, false, false, false]
var players_clutch = [false, false, false, false]
var players_out = [0, 0, 0, 0]
var players_ready = 0

func _ready():
	randomize()
	$Background.texture = texture1

func _process(delta):
	if started:
		var game = load("res://Scenes/Game.tscn").instance()
		game.setup(mode, players_joined)
		$"/root".add_child(game)
		get_tree().current_scene = game
		queue_free()
		return
	
	match state:
		MAIN:
			if Input.is_action_just_pressed("ui_accept"):
				mode = MODES[select]
				state = PLAYERS
				$Background.texture = texture2
			elif Input.is_action_just_pressed("ui_down") and select < MODES.size()-1:
				select += 1
			elif Input.is_action_just_pressed("ui_up") and select > 0:
				select -= 1
		
		PLAYERS:
			players_ready = 0
			var start = true
			
			for i in range(4):
				if Input.is_action_just_pressed("p" + str(i+1) + "_action"):
					if players_in[i]:
						players_out[i] = 1
					else:
						add_player(i)
						players_clutch[i] = true
						
				if Input.is_action_just_released("p" + str(i+1) + "_action"):
					if !players_clutch[i] and players_out[i] < 1.5:
						remove_player(i)
					
					players_out[i] = 0
					players_clutch[i] = false
				
				if players_out[i] > 0:
					players_out[i] += delta
				
				if players_in[i]:
					players_ready += 1
					if players_out[i] < 3:
						start = false
			
			if players_ready > 0 and start:
				started = true
	
	update()

func _draw():
	match state:
		MAIN:
			draw_string(font32, Vector2(260 + sin(OS.get_ticks_msec() / 64.0) * 8, 360 + select * 40), "o", Color(0.5, 1, 1))
			for i in range(MODES.size()):
				draw_string(font32, Vector2(300, 360 + i * 40), MODE_NAMES[MODES[i]], Color(0, 1, 1))
	
		PLAYERS:
			for i in range(4):
				var x = 60 + i*240
				
				var j = players_joined[i]
				if j > -1:
					draw_string(font16, Vector2(x, 360), "GRACZ " + str(i+1), Com.PLAYER_COLORS[i])
					if players_out[j] > 3: draw_string(font16, Vector2(x + 100, 360), "GOTOWY!", Com.PLAYER_COLORS[i])
					
					display_button(Vector2(x + 64, 380), j, "forward")
					display_button(Vector2(x, 428), j, "left")
					display_button(Vector2(x + 64, 428), j, "action")
					display_button(Vector2(x + 128, 428), j, "right")
					display_button(Vector2(x + 64, 476), j, "down")
				else:
					draw_string(font16, Vector2(x, 360), "WCIŚNIJ AKCJĘ", Color(0, 1, 1))
					draw_string(font16, Vector2(x, 380), "BY DOŁĄCZYĆ", Color(0, 1, 1))
				
				if !players_in[i]:
					display_button(Vector2(x + 64, 120), i, "action")
			
			if players_ready > 0 and OS.get_ticks_msec() % 500 < 250:
				draw_string(font16, Vector2(300, 550), "PRZYTRZYMAJ AKCJĘ, BY ROZPOCZĄĆ", Color(0, 1, 1))
				draw_string(font16, Vector2(300, 580), "WCIŚNIJ AKCJĘ, BY SIĘ WYCOFAĆ", Color(0, 1, 1))
				
func add_player(i):
	players_in[i] = true
	
	for j in range(4):
		if players_joined[j] == -1:
			players_joined[j] = i
			return

func remove_player(i):
	players_in[i] = false
	
	for j in range(4):
		if players_joined[j] == i:
			players_joined[j] = -1
			return

func action_text(player, action):
	return InputMap.get_action_list("p" + str(player+1) +"_" + action)[0].as_text()

func display_button(pos, player, action):
	draw_texture(key, pos)
	draw_string(font16, pos + Vector2(18, 32), action_text(player, action), Color(0, 0, 0))