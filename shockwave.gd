extends Area2D

@export var growth_speed: float = 50.0
@export var max_radius: float = 20.0
@export var attack_damage: int = 20

var radius: float = 10.0

func _ready():
	# Garante que a área detecta colisões
	monitoring = true
	monitorable = true
	$CollisionShape2D.disabled = false
	
	# Conecta o sinal corretamente no Godot 4
	self.body_entered.connect(Callable(self, "_on_body_entered"))

func _process(delta):
	# Cresce a onda
	radius += growth_speed * delta
	scale = Vector2.ONE * (radius / 32.0)
	$CollisionShape2D.shape.radius = radius  # atualiza o CollisionShape

	# Destrói após atingir tamanho máximo
	if radius >= max_radius:
		queue_free()

func _on_body_entered(body):
	# Aplica dano se o corpo estiver no grupo "player"
	if body.is_in_group("player"):
		if body.has_method("take_damage"):
			body.take_damage(attack_damage)
