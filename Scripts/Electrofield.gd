tool
extends Node2D

const FORCE = 50

var time = 0

export var width = 64 setget set_width
export var height = 64 setget set_height
export var elevation = 0 setget set_elevation

var players_in = []

func _ready():
	$Shape.shape = RectangleShape2D.new()
	$Shape.shape.extents.x = width/2
	$Shape.shape.extents.y = height/2
	$Sprite.region_rect.size.x = 128
	$Sprite.scale.x = width/128.0
	$Sprite.region_rect.size.y = height

func _physics_process(delta):
	for player in players_in:
		if !player.pause: player.velocity += Vector2(sin(rotation), -cos(rotation)) * FORCE * player.charge
#		if !player.pause: player.velocity += FORCE_V[direction] * FORCE * player.charge
	
	time += 1
	if time % 16 == 0: $Sprite.region_rect.position.y += 32
#	$Sprite.rotation_degrees = direction * 90 ##do poprawienia, bo nie działa z prostokątnym polem

func set_width(neww):
	width = neww
	if has_node("Shape"):
		$Shape.shape.extents.x = neww/2
#		$Sprite.region_rect.size.x = neww
		$Sprite.scale.x = neww/128.0

func set_height(newh):
	height = newh
	if has_node("Shape"):
		$Shape.shape.extents.y = newh/2
		$Sprite.region_rect.size.y = newh

func set_elevation(newe):
	elevation = newe
	set_collision_layer_bit(newe, true)
	set_collision_layer_bit(1 - newe, false)
	set_collision_mask_bit(newe, true)
	set_collision_mask_bit(1 - newe, false)

func _on_enter(body):
	if body.is_in_group("players"):
		players_in.append(body)

func _on_exit(body):
	if body.is_in_group("players"):
		players_in.erase(body)