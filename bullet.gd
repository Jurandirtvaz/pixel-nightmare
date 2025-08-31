extends Area2D

@export var speed: float = 250
var direction: Vector2 = Vector2.ZERO

func _physics_process(delta):
	position += direction * speed * delta

func _on_body_entered(body):
	if body.is_in_group("player"): # player precisa estar no grupo "player"
		body.take_damage(10)       # chama função do player
		queue_free()
