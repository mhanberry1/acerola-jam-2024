extends Node

class_name Rewinder

const UPDATE_INTERVAL := 0.1
const _MAX_HISTORY_SIZE := 100

static var rewinding := false
static var _history : Array[Record] = []
static var _time_to_update := 0.0

class Record:
	var node_ref: Node2D
	var positions: Array[Vector2]
	var popped_positions: Array[Vector2]
	
	func _init(node: Node2D):
		self.node_ref = node
		self.positions = [node.position]
		self.popped_positions = []

static func track(node: Node2D) -> Record:
	var record = Record.new(node)

	_history.append(record)

	return record

static func start():
	rewinding = true

	for record in _history:
		record.popped_positions = []

static func stop():
	rewinding = false

func _update_history():
	for record in _history:
		record.positions.append(record.node_ref.position)
		if len(record.positions) > _MAX_HISTORY_SIZE:
			record.positions.pop_front()

func _rewind():
	var done_rewinding = true
	
	for record in _history:
		if record.positions.is_empty(): continue
		
		record.node_ref.position = record.positions.pop_back()
		record.popped_positions.push_front(record.node_ref.position)
		done_rewinding = done_rewinding and record.positions.is_empty()
	
	if done_rewinding: return Rewinder.stop()

func _process(delta: float):
	if rewinding: return _rewind()
	if _time_to_update > 0:
		_time_to_update -= delta
		return

	_update_history()
	_time_to_update = UPDATE_INTERVAL
