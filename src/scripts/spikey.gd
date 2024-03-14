extends CharacterBody2D

enum Direction { LEFT, RIGHT }

@export var speed := -10.0
@export var rotation_speed := 1
@export var starting_direction := Direction.LEFT

var action = ""
var animation = ""
var _death_handler : DeathHandler
var _original_modulate : Color
var _original_scale : Vector2
var _cooldown := 0.0

func hit():
	action = 'reset'
	_death_handler = DeathHandler.new(self)

func damage():
	if get_tree():
		Rewinder.reset()
		get_tree().reload_current_scene()

func reset():
	print('reset')
	modulate = _original_modulate
	scale = _original_scale
	process_mode = Node.PROCESS_MODE_INHERIT
	_death_handler.queue_free()
	_death_handler = null

func _ready():
	_original_modulate = modulate
	_original_scale = scale
	Rewinder.track(self)

	if starting_direction == Direction.RIGHT:
		speed *= -1
		$AnimatedSprite2D.flip_h = not $AnimatedSprite2D.flip_h

func _process(delta):
	if _death_handler: return _death_handler.handle(delta)

	if not is_on_floor(): velocity.y = 100

	if is_on_wall():
		_cooldown -= delta

		if _cooldown <= 0:
			speed *= -1
			$AnimatedSprite2D.flip_h = not $AnimatedSprite2D.flip_h
			_cooldown = 0.5

	var target_angle = get_floor_normal().angle() + PI / 2
	
	if is_on_floor() and rotation < target_angle:
		rotation += min(rotation_speed * delta, target_angle - rotation)
	elif is_on_floor() and rotation > target_angle:
		rotation -= min(rotation_speed * delta, rotation - target_angle)

	velocity.x = speed
	
	move_and_slide()
