extends Node

class_name Rewinder

const UPDATE_INTERVAL := 0.1
const REWIND_INTERVAL := 0.03
const _MAX_HISTORY_SIZE := 100

static var rewinding := false
static var _history : Array[Record] = []
static var _time_to_update := 0.0
static var _time_to_rewind := 0.0

class State:
	var transform : Transform2D
	var action : String
	var animation : String

	func _init(node : Node2D):
		self.transform = node.transform
		self.action = node.action
		self.animation = node.animation

		node.action = ""
	
	func _to_string():
		return '%s %s' % [transform, action]

class Record:
	var node_ref : Node2D
	var states : Array[State]
	var popped_states : Array[State]

	func _init(node : Node2D):
		self.node_ref = node
		self.states = [State.new(node)]
		self.popped_states = []

static func track(node : Node2D) -> Record:
	var record = Record.new(node)

	_history.append(record)

	return record

static func start():
	rewinding = true

	for record in _history:
		record.popped_states = []

static func stop():
	rewinding = false
	_time_to_update = UPDATE_INTERVAL
	_time_to_rewind = REWIND_INTERVAL

func _update_history(delta : float):
	if _time_to_update > 0:
		_time_to_update -= delta
		return

	for record in _history:
		record.states.append(State.new(record.node_ref))
		if len(record.states) > _MAX_HISTORY_SIZE:
			record.states.pop_front()

	_time_to_update = UPDATE_INTERVAL

func _rewind(delta : float):
	if _time_to_rewind > 0:
		_time_to_rewind -= delta
		return

	_time_to_rewind = REWIND_INTERVAL
	
	for record in _history:
		if record.states.is_empty(): continue
		
		var state = record.states.pop_back()

		if state.action and state.action in record.node_ref:
			record.node_ref.call(state.action)

		record.node_ref.transform = state.transform
		record.popped_states.push_front(state)

func _process(delta : float):
	if rewinding: return _rewind(delta)

	_update_history(delta)
