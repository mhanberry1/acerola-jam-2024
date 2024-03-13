extends CharacterBody2D

@export var speed := 300
@export var gravity := 1000
@export var jump_force := 400
@export var max_jump_duration := 0.1

@onready var _animated_sprite = $AnimatedSprite2D

var action = ""
var animation = ""
var _duplicate = preload('res://components/duplicate.tscn')
var _bullet = preload('res://components/bullet.tscn')
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
				_history_record.popped_states.duplicate()
			)
		)

func _handle_shoot():
	if Input.is_action_just_pressed("shoot"):
		var new_bullet : StaticBody2D = _bullet.instantiate()

		if _animated_sprite.flip_h: new_bullet.flip()
		
		action = "shoot"
		$/root/Main.add_child(new_bullet)
		new_bullet.show()
		new_bullet.position = $bulletspawn.global_position

func _play_animations():
	if not is_on_floor():
		animation = "jump"
	elif Input.is_action_pressed("right"):
		animation = "walk"
		action = "right"

		if _animated_sprite.flip_h:
			_animated_sprite.position.x *= -1
			$bulletspawn.position.x *= -1
			_animated_sprite.flip_h = false

	elif Input.is_action_pressed("left"):
		animation = "walk"
		action = "left"

		if not _animated_sprite.flip_h:
			_animated_sprite.position.x *= -1
			$bulletspawn.position.x *= -1
			_animated_sprite.flip_h = true

	else:
		animation = "stand"
	
	_animated_sprite.play(animation)

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
