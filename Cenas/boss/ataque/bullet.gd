extends Area2D

@export var speed: float = 600
@export var damage: int = 1
var direction: Vector2 = Vector2.ZERO


func _ready():
	connect("body_entered", Callable(self, "_on_body_entered"))

func _physics_process(delta):
	position += direction * speed * delta

func _on_body_entered(body):
	if body.is_in_group("player"):
		if body.has_method("tomar_dano"):
			body.tomar_dano()
	queue_free()
