# Boss.gd
extends CharacterBody2D

@export var speed: float = 100
@export var wait_time: float = 1.0
@export var attack_damage: int = 20

var player: CharacterBody2D = null
var target_position: Vector2
var moving: bool = false
var state_timer: Timer

func _ready():
	# Timer
	state_timer = Timer.new()
	state_timer.one_shot = true
	state_timer.timeout.connect(Callable(self, "_on_state_timer_timeout"))
	add_child(state_timer)

	# Pega player pelo grupo
	var players = get_tree().get_nodes_in_group("player")
	if players.size() > 0:
		player = players[0]
		_go_to_player()
	else:
		get_tree().connect("node_added", Callable(self, "_on_node_added"))

func _physics_process(delta):
	if moving and player:
		var dir = (target_position - global_position).normalized()
		velocity = dir * speed
		move_and_slide()

		# Chegou no player? Ataca
		if global_position.distance_to(target_position) < 10:
			velocity = Vector2.ZERO
			moving = false
			attack()
			state_timer.start(wait_time)

func _on_state_timer_timeout():
	if player:
		_go_to_player()

func _go_to_player():
	if player:
		target_position = player.global_position
		moving = true

func _on_node_added(node):
	if node.is_in_group("player"):
		player = node
		_go_to_player()
		get_tree().disconnect("node_added", Callable(self, "_on_node_added"))

# ======================
#      ATAQUE
# ======================

func attack():
	# Instancia a onda de impacto
	var wave_scene = preload("res://Shockwave.tscn")
	var wave = wave_scene.instantiate()
	wave.global_position = global_position
	wave.attack_damage = attack_damage  # caso queira passar dano para a onda
	get_parent().add_child(wave)
