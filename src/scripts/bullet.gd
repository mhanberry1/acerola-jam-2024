extends StaticBody2D

@export var speed := 5
@export var lifetime := 1.0 

var _shooting := false
var _position_y : float

func flip():
	$Sprite2D.flip_h = true
	speed *= -1
	position.x *= -1

func shoot():
	_shooting = true

func _handle_collision():
	var collision := move_and_collide(Vector2())

	if collision: queue_free()

func _ready():
	_position_y = global_position.y

func _process(delta):
	if not _shooting: return

	global_position.x += speed
	global_position.y = _position_y
	lifetime -= delta

	_handle_collision()

	if lifetime > 0: return

	queue_free()
