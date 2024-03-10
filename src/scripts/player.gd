extends CharacterBody2D

@export var speed := 300
@export var gravity := 1000
@export var jump_force := 400
@export var max_jump_duration := 0.1

@onready var _animated_sprite = $AnimatedSprite2D

var _duplicate = preload('res://components/duplicate.tscn')
var _history_record : Rewinder.Record
var _jump_duration := 0.0

func _handle_gravity(delta: float):
	if not Rewinder.rewinding: velocity.y += gravity * delta

func _handle_movement(delta: float):
	velocity.x = 0
	
	if not Input.is_action_pressed("jump") and is_on_floor():
		_jump_duration = 0

	if Input.is_action_pressed("left"): velocity.x = -speed
	if Input.is_action_pressed("right"): velocity.x = speed
	if Input.is_action_pressed("jump") and _jump_duration < max_jump_duration:
		velocity.y = -jump_force
		_jump_duration += delta
	if Input.is_action_just_released("jump"): _jump_duration = max_jump_duration

func _handle_rewind():
	if Input.is_action_just_pressed("rewind"):
		Rewinder.start()
	if Input.is_action_just_released("rewind"):
		Rewinder.stop()
		$/root/Main.add_child(
			_duplicate.instantiate().setup(
				_history_record.popped_positions.duplicate()
			)
		)

func _handle_shoot():
	if Input.is_action_just_pressed("shoot"):
		var bullet : StaticBody2D = $bullet.duplicate()

		if _animated_sprite.flip_h: bullet.flip()
		
		add_child(bullet)
		bullet.show()
		bullet.shoot()

func _play_animations():
	if not is_on_floor():
		_animated_sprite.play("jump")
	elif Input.is_action_pressed("right"):
		if _animated_sprite.flip_h:
			_animated_sprite.position.x *= -1

		_animated_sprite.flip_h = false
		_animated_sprite.play("walk")
	elif Input.is_action_pressed("left"):
		if not _animated_sprite.flip_h:
			_animated_sprite.position.x *= -1

		_animated_sprite.flip_h = true
		_animated_sprite.play("walk")
	else:
		_animated_sprite.play("stand")

func _ready():
	_history_record = Rewinder.track(self)

func _physics_process(delta: float):
	_handle_rewind()

	if Rewinder.rewinding: return

	_handle_gravity(delta)
	_handle_movement(delta)
	_handle_shoot()
	_play_animations()

	move_and_slide()
