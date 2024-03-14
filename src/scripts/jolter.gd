extends CharacterBody2D

enum Direction { LEFT, RIGHT }

@export var speed := -200.0
@export var starting_direction := Direction.LEFT

var action = ""
var animation = ""
var _death_handler : DeathHandler
var _original_modulate : Color
var _original_scale : Vector2

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

	if is_on_wall():
		speed *= -1
		$AnimatedSprite2D.flip_h = not $AnimatedSprite2D.flip_h

	velocity.x = speed
	
	move_and_slide()
