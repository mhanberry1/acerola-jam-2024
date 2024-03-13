extends AnimatableBody2D

class_name Duplicate

const _EVAPORATE_DURATION := 2.0

var states : Array[Rewinder.State]
var _bullet = preload('res://components/bullet.tscn')
var _time_to_update := Rewinder.UPDATE_INTERVAL
var _target : Rewinder.State

func setup(states: Array[Rewinder.State]) -> Duplicate:
	self.states = states
	return self

func evaporate(delta: float):
	if modulate.a <= 0: queue_free()

	modulate.a -= delta / _EVAPORATE_DURATION

func left():
	$bulletspawn.position.x *= 1 if $AnimatedSprite2D.flip_h else -1
	$AnimatedSprite2D.flip_h = true

func right():
	$bulletspawn.position.x *= -1 if $AnimatedSprite2D.flip_h else 1
	$AnimatedSprite2D.flip_h = false

func shoot():
	var new_bullet : StaticBody2D = _bullet.instantiate()

	if $AnimatedSprite2D.flip_h: new_bullet.flip()
	
	$/root/Main.add_child(new_bullet)
	new_bullet.show()
	new_bullet.position = $bulletspawn.global_position

func _play_animations():
	if not _target: return

	if position == _target.transform.get_origin():
		$AnimatedSprite2D.play("stand")
	else:
		$AnimatedSprite2D.play("walk")

func _ready():
	if states.is_empty(): return

	var state = states.pop_front()

	transform = state.transform

	if state.action: call(state.action)

func _process(delta: float):
	if states.is_empty(): return evaporate(delta)

	_play_animations()
	_time_to_update -= delta

	if _target:
		var modifier = (delta / Rewinder.UPDATE_INTERVAL)
		var delta_rotation = _target.transform.get_rotation() - rotation
		var delta_position = _target.transform.get_origin() - position

		transform = Transform2D(
			rotation + delta_rotation * modifier,
			_target.transform.get_scale(),
			_target.transform.get_skew(),
			position + delta_position * modifier,
		)

	if _time_to_update > 0: return

	if _target and _target.action:
		call(_target.action)

	_target = states.pop_front()
	_time_to_update = Rewinder.UPDATE_INTERVAL
