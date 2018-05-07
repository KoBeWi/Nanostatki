extends Node2D

const CAMERA_SPEED = 16
const ACTIVE_TIME = 1.5
const SMUTECZEK = "Wygląda na to, że niczego tu nie ma :("
const DOT_SPAWN = 0.05

onready var camera_target = $Camera.position
onready var video = $Modes/VideoPlayer
var modenames = Com.load_nodenames()
var videos = Com.load_videos()
var tracks = Com.load_tracks()
var arenas = Com.load_arenas()

var screen = "Title"
var choice setget move_selection
var exiting
var prev_node
var modename_visible
var dot_delay = 0
var possible_spawns = []

var gamemode
var options = [1, 1]

var players_joined = [-1, -1, -1, -1]
var players_in = [false, false, false, false]
var players_clutch = [false, false, false, false]
var players_out = [0, 0, 0, 0]
var players_ready = 0
var start

func _ready():
	$Modes.remove_child(video)
	self.choice = 1
	Jukebox.play_music("IDY")
	
	for x in range(-4, 4):
		for y in range(-2, 3):
			possible_spawns.append(Vector2(x, y))
	
	for j in range(2):
		Com.load_scoreboard("Race" + str(j+1))
		var names = ""
		var scores = ""
		for i in range(9):
			var spot = Com.get_score(i)
			if spot:
				names += "#" + str(i+1) + "   " + spot.name + "\n"
				scores += Com.format_time(-int(spot.score)) + "\n"
		get_node("Scores/Tables/Race/Track" + str(j+1) + "/Names").text = (names if names != "" else SMUTECZEK)
		get_node("Scores/Tables/Race/Track" + str(j+1) + "/Scores").text = scores
	
	Com.load_scoreboard("Sumo")
	var names = ""
	var scores = ""
	for i in range(9):
		var spot = Com.get_score(i)
		if spot:
			names += "#" + str(i+1) + "   " + spot.name + "\n"
			scores += str(spot.score) + " pkt\n"
	get_node("Scores/Tables/Sumo/Names").text = (names if names != "" else SMUTECZEK)
	get_node("Scores/Tables/Sumo/Scores").text = scores
	
	for j in range(7):
		Com.load_scoreboard("Arena" + str(j+1))
		names = ""
		scores = ""
		for i in range(4):
			var spot = Com.get_score(i)
			if spot:
				names += "#" + str(i+1) + "   " + spot.name + "\n"
				scores += str(Com.round_float(spot.score, 3)) + "pkt/s\n"
		get_node("Scores/Tables/Arena/Arena" + str(j+1) + "/Names").text = (names if names != "" else "Pusto :(")
		get_node("Scores/Tables/Arena/Arena" + str(j+1) + "/Scores").text = scores
	
	Com.load_scoreboard("Drag")
	names = ""
	scores = ""
	for i in range(9):
		var spot = Com.get_score(i)
		if spot:
			names += "#" + str(i+1) + "   " + spot.name + "\n"
			scores += str(spot.score) + " nm\n"
	get_node("Scores/Tables/Drag/Names").text = (names if names != "" else SMUTECZEK)
	get_node("Scores/Tables/Drag/Scores").text = scores
	
	Com.load_scoreboard("Survival")
	names = ""
	scores = ""
	for i in range(9):
		var spot = Com.get_score(i)
		if spot:
			names += "#" + str(i+1) + "   " + spot.name + "\n"
			scores += str(spot.score) + " nm\n"
	get_node("Scores/Tables/Survival/Names").text = (names if names != "" else SMUTECZEK)
	get_node("Scores/Tables/Survival/Scores").text = scores

func _process(delta):
	if Input.is_action_just_pressed("ui_right") and choice < get_node(screen + "/Nodes").get_child_count()-1:
		self.choice += 1
	elif Input.is_action_just_pressed("ui_left") and choice > 0:
		self.choice -= 1
	
	if Input.is_action_just_pressed("ui_cancel"):
		match screen:
			"Modes":
				camera_target = $ScreenPositions/Title.position
				self.choice = -1
				screen = "Title"
				self.choice = 1
			
			"Authors":
				camera_target = $ScreenPositions/Title.position
				self.choice = -1
				screen = "Title"
				self.choice = 2
			
			"Lobby":
				var players_joined = [-1, -1, -1, -1]
				var players_in = [false, false, false, false]
				var players_clutch = [false, false, false, false]
				var players_out = [0, 0, 0, 0]
				get_node("Modes/Lines/" + Com.MODES[gamemode]).end = "../../../ScreenPositions/" + Com.MODES[gamemode] + "/Position2D"
				get_node("Modes/Lines/" + Com.MODES[gamemode]).visible = false
				camera_target = $ScreenPositions/Modes.position
				screen = "Modes"
				self.choice = gamemode
			
			"Scores":
				camera_target = $ScreenPositions/Title.position
				self.choice = -1
				screen = "Title"
				self.choice = 0
	
	if Input.is_action_just_pressed("ui_accept"):
		match [screen, choice]:
			["Title", 0]:
				camera_target = $ScreenPositions/Scores.position
				self.choice = -1
				screen = "Scores"
				self.choice = 5
			
			["Title", 1]:
				camera_target = $ScreenPositions/Modes.position
				self.choice = -1
				screen = "Modes"
				self.choice = 0
				
			["Title", 2]:
				camera_target = $ScreenPositions/Authors.position
				self.choice = -1
				screen = "Authors"
				self.choice = 0
			
			["Title", 3]:
				camera_target.x = 10000
				exiting = 1
				yield(get_tree().create_timer(1.5), "timeout")
				get_tree().quit()
				
			["Scores", 5]:
				camera_target = $ScreenPositions/Title.position
				self.choice = -1
				screen = "Title"
				self.choice = 0
			
			["Authors", 0]:
				camera_target = $ScreenPositions/Title.position
				self.choice = -1
				screen = "Title"
				self.choice = 2
			
			["Modes", _]:
				$Samples/Move.play()
				goto_lobby(choice)
				return
	
	if screen == "Lobby":
		if gamemode == 0:
			if Input.is_action_just_pressed("ui_right") and options[0] < 2:
				options[0] += 1
				$Lobby/RaceArena/Horizontal.off_balance = Vector2(16, 0)
				$Lobby/RaceArena/Horizontal/Fill/HorizontalNumber.text = str(options[0])
				$Lobby/RaceArena/Frame/Preview.texture = tracks[options[0]-1]
			elif Input.is_action_just_pressed("ui_left") and options[0] > 1:
				options[0] -= 1
				$Lobby/RaceArena/Horizontal.off_balance = Vector2(-16, 0)
				$Lobby/RaceArena/Horizontal/Fill/HorizontalNumber.text = str(options[0])
				$Lobby/RaceArena/Frame/Preview.texture = tracks[options[0]-1]
			elif Input.is_action_just_pressed("ui_up") and options[1] < 9:
				options[1] += 1
				$Lobby/RaceArena/Vertical.off_balance = Vector2(0, -16)
				$Lobby/RaceArena/Vertical/Fill/VerticalNumber.text = str(options[1])
			elif Input.is_action_just_pressed("ui_down") and options[1] > 1:
				options[1] -= 1
				$Lobby/RaceArena/Vertical.off_balance = Vector2(0, 16)
				$Lobby/RaceArena/Vertical/Fill/VerticalNumber.text = str(options[1])
				$Lobby/RaceArena/Vertical/Fill/VerticalNumber.text = str(options[1])
			elif Input.is_action_just_pressed("ui_randomize"):
				options[0] = 1 + randi() % 2
				$Lobby/RaceArena/Dice.off_balance = Vector2(randi() % 16, randi() % 16)
				$Lobby/RaceArena/Horizontal/Fill/HorizontalNumber.text = str(options[0])
				$Lobby/RaceArena/Frame/Preview.texture = tracks[options[0]-1]
		elif gamemode == 3:
			if Input.is_action_just_pressed("ui_right") and options[0] < 7:
				options[0] += 1
				$Lobby/RaceArena/Horizontal.off_balance = Vector2(16, 0)
				$Lobby/RaceArena/Horizontal/Fill/HorizontalNumber.text = str(options[0])
				$Lobby/RaceArena/Frame/Preview.texture = arenas[options[0]-1]
			elif Input.is_action_just_pressed("ui_left") and options[0] > 1:
				options[0] -= 1
				$Lobby/RaceArena/Horizontal.off_balance = Vector2(-16, 0)
				$Lobby/RaceArena/Horizontal/Fill/HorizontalNumber.text = str(options[0])
				$Lobby/RaceArena/Frame/Preview.texture = arenas[options[0]-1]
			elif (Input.is_action_just_pressed("ui_up") or !Input.is_key_pressed(KEY_SHIFT) and Input.is_action_pressed("ui_up")) and options[1] < 300:
				options[1] += 1
				$Lobby/RaceArena/Vertical.off_balance = Vector2(0, -16)
				$Lobby/RaceArena/Vertical/Fill/VerticalNumber.text = str(options[1])
			elif (Input.is_action_just_pressed("ui_down") or !Input.is_key_pressed(KEY_SHIFT) and Input.is_action_pressed("ui_down")) and options[1] > 15:
				options[1] -= 1
				$Lobby/RaceArena/Vertical.off_balance = Vector2(0, 16)
				$Lobby/RaceArena/Vertical/Fill/VerticalNumber.text = str(options[1])
				$Lobby/RaceArena/Vertical/Fill/VerticalNumber.text = str(options[1])
			elif Input.is_action_just_pressed("ui_randomize"):
				options[0] = 1 + randi() % 7
				$Lobby/RaceArena/Dice.off_balance = Vector2(randi() % 16, randi() % 16)
				$Lobby/RaceArena/Horizontal/Fill/HorizontalNumber.text = str(options[0])
				$Lobby/RaceArena/Frame/Preview.texture = arenas[options[0]-1]
		
		players_ready = 0
		start = true
		
		for i in range(4):
			if Input.is_action_just_pressed("p" + str(i+1) + "_action"):
				if players_in[i]:
					players_out[i] = 1
				else:
					$Samples/Join.play()
					add_player(i)
					players_clutch[i] = true
					
			if Input.is_action_just_released("p" + str(i+1) + "_action"):
				if players_in[i] and !players_clutch[i] and players_out[i] < 1.5:
					$Samples/Leave.play()
					remove_player(i)
				
				players_out[i] = 0
				players_clutch[i] = false
			
			if players_out[i] > 0:
				players_out[i] += delta
			
			if players_in[i]:
				players_ready += 1
				var node = get_node("Lobby/Players/" + str(i+1) + "Active")
				if players_out[i] < ACTIVE_TIME:
					start = false
					node.modulate = Color(1, 1, 1)
				else:
					if node.modulate == Color(1, 1, 1): Com.play_sample(self, "Ready", false)
					node.modulate = Com.PLAYER_COLORS[i]
			
			get_node("Lobby/Players/" + str(i+1) + "Inactive").visible = !players_in[i]
			get_node("Lobby/Players/" + str(i+1) + "Active").visible = players_in[i]
		
		if players_ready > (1 if gamemode == 2 else 0) and start:
			Jukebox.stop()
			var game = load("res://Scenes/Loading.tscn").instance()
			game.setup = [Com.MODES[gamemode], players_joined, options]
			$"/root".add_child(game)
			get_tree().current_scene = game
			queue_free()
		
		$Lobby/Need2.visible = (gamemode == 2 and players_ready == 1)
		$Lobby/RealContinue.visible = (players_ready > 0)
	
	if dot_delay <= 0:
		dot_delay = DOT_SPAWN
		
		var spawn = possible_spawns[randi() % possible_spawns.size()]
		possible_spawns.erase(spawn)
		var dot = preload("res://Nodes/Effects/MenuDot.tscn").instance()
		dot.set_direction(spawn)
		
		add_child(dot)
		dot.connect("free_spawn", self, "free_spawn")
		dot.position = $Camera.position + Vector2(64 + spawn.x * 128, spawn.y * 128)
	else:
		dot_delay -= delta
	
	var speed = max((camera_target - $Camera.position).length()/10, CAMERA_SPEED)
	if exiting: speed = CAMERA_SPEED
	$Camera.position += (camera_target - $Camera.position).normalized() * speed
	if $Camera.position.distance_squared_to(camera_target) < speed*speed: $Camera.position = camera_target
	
	if exiting:
		exiting -= delta
		modulate = Color(exiting, exiting, exiting)
		$ParallaxBackground/ParallaxLayer/Background.modulate = Color(exiting, exiting, exiting)

func free_spawn(spawn):
	possible_spawns.append(spawn)

func move_selection(new_choice):
	choice = new_choice
	
	var menus = get_node(screen + "/Nodes")
	for i in range(menus.get_child_count()):
		var menu = menus.get_child(i)
		
		if i == choice:
			var color = menu.get_node("Fill/Icon").self_modulate
			menu.get_node("Fill").self_modulate = Color(0, 0.5, 1)
			menu.self_modulate = Color(0, 0.5, 1)
#			menu.get_node("Fill/Icon").self_modulate = Color(1, 1, 1)
			
			if prev_node:
				menu.impulse(prev_node)
			prev_node = menu
		else:
			if menu.self_modulate != Color(1, 1, 1):
#				menu.get_node("Fill/Icon").self_modulate = menu.self_modulate
				menu.get_node("Fill").self_modulate = Color(1, 1, 1)
				menu.self_modulate = Color(1, 1, 1)
	
	if screen == "Modes":
		$Modes/Modename.texture = modenames[choice]
		for mode in $Modes/Nodes.get_children():
			if mode.has_node("VideoPlayer"): mode.remove_child(video)
		get_node("Modes/Nodes/" + Com.MODES[choice]).add_child(video)
		video.rect_position = Vector2(-64, -64)
		video.stream = videos[choice]
		video.play()
	elif screen == "Scores":
		for i in range(5):
			$Scores/Tables.get_child(i).visible = (choice == i)

func add_player(i):
	players_in[i] = true
	players_joined[i] = i
	return #;_;
	
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

func goto_lobby(i, teleport = false):
	modename_visible = false
	gamemode = i
	if teleport: $Camera.position = get_node("ScreenPositions/" + Com.MODES[gamemode]).position
	camera_target = get_node("ScreenPositions/" + Com.MODES[gamemode]).position
	
	$Lobby.position = camera_target
	$Lobby/Return.position = get_node("ScreenPositions/" + Com.MODES[gamemode] + "/Position2D").position
	$Lobby/Return.start_pos = $Lobby/Return.position
	get_node("Modes/Lines/" + Com.MODES[gamemode]).visible = true
	get_node("Modes/Lines/" + Com.MODES[gamemode]).end = NodePath("../../../Lobby/Return")
	
	self.choice = -1
	screen = "Lobby"
	
	$Lobby/RaceArena.visible = (gamemode == 0 or gamemode == 3)
	$Lobby/RaceArena/RaceText.visible = (gamemode == 0)
	$Lobby/RaceArena/ArenaText.visible = (gamemode == 3)
	
	options[0] = 1
	if gamemode == 0: options[1] = 3
	elif gamemode == 3: options[1] = 90
	$Lobby/RaceArena/Horizontal/Fill/HorizontalNumber.text = str(options[0])
	$Lobby/RaceArena/Vertical/Fill/VerticalNumber.text = str(options[1])
	$Lobby/RaceArena/Frame/Preview.texture = (tracks[options[0]-1] if gamemode == 0 else arenas[options[0]-1])