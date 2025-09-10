extends Area2D

@export var growth_speed: float = 80.0
@export var max_radius: float = 80.0
@export var attack_damage: int = 1
@export var debug: bool = true

var radius: float = 20.0
@onready var colshape: CollisionShape2D = $CollisionShape2D

func _ready():
	monitoring = true
	monitorable = true
	colshape.disabled = false

	self.body_entered.connect(Callable(self, "_on_body_entered"))

	call_deferred("_check_initial_overlaps")

	if debug:
		print("Shockwave _ready. radius:", radius)

func _check_initial_overlaps():
	var bodies = get_overlapping_bodies()
	if debug:
		print("Check initial overlaps ->", bodies.size(), "bodies")
	for b in bodies:
		_on_body_entered(b)

func _process(delta):
	radius += growth_speed * delta

	if colshape.shape is CircleShape2D:
		colshape.shape.radius = radius

	scale = Vector2.ONE * (radius / 32.0)

	if radius >= max_radius:
		queue_free()

func _on_body_entered(body):
	if debug:
		print("Shockwave: body_entered ->", body.name, "groups:", body.get_groups())
	if body.is_in_group("player"):
		if body.has_method("tomar_dano"):
			body.tomar_dano()
