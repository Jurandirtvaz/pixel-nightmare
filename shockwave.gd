extends Area2D

@export var growth_speed: float = 200.0
@export var max_radius: float = 300.0
var radius: float = 10.0

func _process(delta):
	radius += growth_speed * delta
	scale = Vector2.ONE * (radius / 32.0) # ajusta conforme sprite base
	if radius >= max_radius:
		queue_free()
