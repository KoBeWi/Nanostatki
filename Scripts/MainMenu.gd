extends Node2D

const CAMERA_SPEED = 4
const ACTIVE_TIME = 1.5
const MODES = ["Race", "Drag", "Sumo", "Arena", "Survival"]

onready var camera_target = $Camera.position
var modenames = Com.load_nodenames()
var videos = Com.load_videos()

var screen = "Title"
var choice setget move_selection
var exiting
var prev_node
var modename_visible

var gamemode
var options = [1, 1]

var players_joined = [-1, -1, -1, -1]
var players_in = [false, false, false, false]
var players_clutch = [false, false, false, false]
var players_out = [0, 0, 0, 0]
var players_ready = 0
var start

func _ready():
	self.choice = 1
	Jukebox.play_music("IDY")

func _process(delta):
	if Input.is_action_just_pressed("ui_right") and choice < get_node(screen + "/Nodes").get_child_count()-1:
		self.choice += 1
	elif Input.is_action_just_pressed("ui_left") and choice > 0:
		self.choice -= 1
	
	if Input.is_action_just_pressed("ui_cancel"):
		match screen:
			"Modes":
				camera_target = Vector2(512, 300)
				self.choice = -1
				screen = "Title"
				self.choice = 1
			
			"Authors":
				camera_target = Vector2(512, 300)
				self.choice = -1
				screen = "Title"
				self.choice = 2
			
			"Lobby":
				camera_target = Vector2(1082, 987)
				screen = "Modes"
				self.choice = gamemode+1
	
	if Input.is_action_just_pressed("ui_accept"):
		match [screen, choice]:
			["Title", 1]:
				camera_target = Vector2(1082, 987)
				self.choice = -1
				screen = "Modes"
				self.choice = 1
				
			["Title", 2]:
				camera_target = Vector2(1512, -526)
				self.choice = -1
				screen = "Authors"
				self.choice = 0
			
			["Title", 3]:
				camera_target.x = 10000
				exiting = 1
				yield(get_tree().create_timer(1.1), "timeout")
				get_tree().quit()
			
			["Authors", 0]:
				camera_target = Vector2(512, 300)
				self.choice = -1
				screen = "Title"
				self.choice = 2
			
			["Modes", 0]:
				camera_target = Vector2(512, 300)
				self.choice = -1
				screen = "Title"
				self.choice = 1
			
			["Modes", _]:
				camera_target = Vector2(2501, 1352)
				modename_visible = false
				gamemode = choice-1
				$CrossLines/MODE.start = NodePath("../../Modes/Nodes/" + $Modes/Nodes.get_child(choice).name)
				self.choice = -1
				screen = "Lobby"
				
				$Lobby/RaceArena.visible = (gamemode == 0 or gamemode == 3)
				$Lobby/RaceArena/RaceText.visible = (gamemode == 0)
				$Lobby/RaceArena/ArenaText.visible = (gamemode == 3)
				
				return
	
	if screen == "Lobby":
		players_ready = 0
		start = true
		
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
				if players_out[i] < ACTIVE_TIME:
					start = false
					get_node("Lobby/Players/" + str(i+1) + "Active").modulate = Color(1, 1, 1)
				else:
					get_node("Lobby/Players/" + str(i+1) + "Active").modulate = Com.PLAYER_COLORS[i]
			
			get_node("Lobby/Players/" + str(i+1) + "Inactive").visible = !players_in[i]
			get_node("Lobby/Players/" + str(i+1) + "Active").visible = players_in[i]
		
		if players_ready > 0 and start:
			var game = load("res://Scenes/Loading.tscn").instance()
			game.setup = [MODES[gamemode], players_joined, options]
			$"/root".add_child(game)
			get_tree().current_scene = game
			queue_free()
		
		$Lobby/RealContinue.visible = (players_ready > 0)
	
	$Camera.position += (camera_target - $Camera.position).normalized() * CAMERA_SPEED
	if $Camera.position.distance_squared_to(camera_target) < CAMERA_SPEED*CAMERA_SPEED: $Camera.position = camera_target
	
	if exiting:
		exiting -= 0.005
		$".".modulate = Color(exiting, exiting, exiting)
	
	if modename_visible and $Modes/VideoPanel.modulate.a < 1:
		$Modes/VideoPanel.modulate.a += 0.05
		$Modes/Modename.modulate.a += 0.05
	elif !modename_visible and $Modes/VideoPanel.modulate.a > 0:
		$Modes/VideoPanel.modulate.a -= 0.05
		$Modes/Modename.modulate.a -= 0.05
	elif !modename_visible:
		$Modes/VideoPanel/VideoPlayer.stop()

func move_selection(new_choice):
	choice = new_choice
	
	var menus = get_node(screen + "/Nodes")
	for i in range(menus.get_child_count()):
		var menu = menus.get_child(i)
		
		if i == choice:
			var color = menu.get_node("Fill/Icon").self_modulate
			menu.get_node("Fill").self_modulate = color
			menu.self_modulate = color
			menu.get_node("Fill/Icon").self_modulate = Color(color.r * 2, color.g * 2, color.b * 2)
			
			if prev_node:
				menu.off_balance = (menu.position - prev_node.position)/10
			prev_node = menu
		else:
			if menu.self_modulate != Color(1, 1, 1):
				menu.get_node("Fill/Icon").self_modulate = menu.self_modulate
				menu.get_node("Fill").self_modulate = Color(1, 1, 1)
				menu.self_modulate = Color(1, 1, 1)
	
	if screen == "Modes":
		if choice > 0:
			modename_visible = true
			$Modes/Modename.texture = modenames[choice-1]
			$Modes/VideoPanel/VideoPlayer.stream = videos[choice-1]
			$Modes/VideoPanel/VideoPlayer.play()
		else:
			modename_visible = false

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