extends StaticBody2D

@export var speed := 5
@export var lifetime := 1.0 

func flip():
	$Sprite2D.flip_h = true
	speed *= -1

func _process(delta):
	lifetime -= delta

	var collision := move_and_collide(Vector2(speed, 0))

	if collision:
		var body = collision.get_collider()
		if 'hit' in body: body.hit()
	if collision or lifetime <= 0: queue_free()
