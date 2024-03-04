extends StaticBody2D

class_name Duplicate

const _EVAPORATE_DURATION := 2.0

var positions : Array[Vector2]
var _time_to_update := Rewinder.UPDATE_INTERVAL
var _target : Vector2

func setup(pos: Array[Vector2]) -> Duplicate:
	self.positions = pos
	return self

func evaporate(delta: float):
	if modulate.a <= 0: queue_free()

	modulate.a -= delta / _EVAPORATE_DURATION

func _ready():
	if positions.is_empty(): return

	position = positions.pop_front()

func _process(delta: float):
	if positions.is_empty(): return evaporate(delta)
	
	_time_to_update -= delta

	if _target:
		position += (_target - position) * (delta / Rewinder.UPDATE_INTERVAL)
	
	if _time_to_update > 0: return

	_target = positions.pop_front()
	_time_to_update = Rewinder.UPDATE_INTERVAL
