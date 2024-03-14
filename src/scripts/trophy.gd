extends Area2D

@export var win_text : RichTextLabel

func _process(delta):
	if has_overlapping_bodies(): win_text.visible = true
