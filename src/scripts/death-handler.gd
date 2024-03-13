extends Node

class_name DeathHandler

const DEATH_SPEED := 0.05

var enemy : Node2D
var _time_to_death := DEATH_SPEED

func handle(delta: float):
	if _time_to_death <= 0: return

	var change := delta / DEATH_SPEED

	enemy.modulate += Color(change, change, change)
	enemy.scale += Vector2(change, change)

	_time_to_death -= delta

	if _time_to_death <= 0:
		enemy.process_mode = Node.PROCESS_MODE_DISABLED
		enemy.modulate.a = 0

func _init(enemy : Node2D):
	self.enemy = enemy
