extends Area2D

func _process(delta):
	if not has_overlapping_bodies(): return

	Rewinder.reset()
	get_tree().reload_current_scene()
