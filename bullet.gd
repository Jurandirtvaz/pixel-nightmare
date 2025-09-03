extends Area2D

@export var speed: float = 400
@export var damage: int = 15
var direction: Vector2 = Vector2.ZERO

func _ready():
	connect("body_entered", Callable(self, "_on_body_entered"))

func _physics_process(delta):
	position += direction * speed * delta

func _on_body_entered(body):
	if body.is_in_group("player"):
		if body.has_method("take_damage"):
			body.take_damage(damage)
		queue_free()
