extends Sprite2D

@export var fade_speed: float = 3.0  # Quanto mais rápido, mais rápido some

func _process(delta):
	modulate.a -= fade_speed * delta
	if modulate.a <= 0:
		queue_free()
