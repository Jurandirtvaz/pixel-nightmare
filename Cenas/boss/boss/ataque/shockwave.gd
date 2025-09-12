extends Area2D

@export var attack_radius: float = 10.0        # Raio dano
@export var visual_max_radius: float = 400.0    # Raio visual
@export var visual_growth_speed: float = 200.0 # Crescimento do efeito
@export var visible_time: float = 0.2          # Tempo visível
@export var attack_damage: int = 1
@export var debug: bool = true

@onready var colshape: CollisionShape2D = $CollisionShape2D

var visual_radius: float = 2.0
var bodies_hit: Array = []

func _ready():
	monitoring = true
	monitorable = true
	colshape.disabled = false

	# Colisor mantém o raio de ataque
	if colshape.shape is CircleShape2D:
		colshape.shape.radius = attack_radius

	body_entered.connect(Callable(self, "_on_body_entered"))

	call_deferred("_check_initial_overlaps")

	if debug:
		print("Shockwave _ready. attack_radius:", attack_radius)

func _check_initial_overlaps():
	for b in get_overlapping_bodies():
		_on_body_entered(b)

func _process(delta):
	# Cresce visualmente
	visual_radius += visual_growth_speed * delta
	if visual_radius > visual_max_radius:
		visual_radius = visual_max_radius
		visible_time -= delta
		if visible_time <= 0:
			queue_free()

	scale = Vector2.ONE * (visual_radius / 32.0)

func _on_body_entered(body):
	if body.is_in_group("player") and not bodies_hit.has(body):
		if body.has_method("tomar_dano"):
			body.tomar_dano()
			bodies_hit.append(body)
		if debug:
			print("Player atingido pela onda! Distância:", body.global_position.distance_to(global_position))
