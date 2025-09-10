extends CharacterBody2D

@export var speed: float = 100
@export var wait_time: float = 1.0
@export var attack_damage: int = 20
@export var max_hp: float = 200

var hp: float
var phase2 = false
var hud: Node

var player: CharacterBody2D = null
var target_position: Vector2
var moving: bool = false
var state_timer: Timer

func _ready():
	hp = max_hp
	state_timer = Timer.new()
	state_timer.one_shot = true
	state_timer.timeout.connect(_on_state_timer_timeout)
	add_child(state_timer)
	
	hud = get_tree().get_first_node_in_group("hud")
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
# ATAQUES
# ======================
func attack():
	# Ataque normal (onda de impacto)
	var wave_scene = preload("res://Cenas/boss/ataque/shockwave.tscn")
	var wave = wave_scene.instantiate()
	wave.global_position = global_position
	wave.attack_damage = attack_damage
	get_parent().add_child(wave)

	# Se estiver na fase 2, atira também
	if phase2:
		attack_laser()

func attack_laser():
	if not has_node("ShootPoint") or not player:
		return

	var laser_scene = preload("res://Cenas/boss/ataque/bullet.tscn")
	var laser = laser_scene.instantiate()
	laser.global_position = $ShootPoint.global_position
	laser.direction = (player.global_position - $ShootPoint.global_position).normalized()
	get_parent().add_child(laser)

# ======================
# DANO
# ======================
func receber_dano(amount):
	hp = clamp(hp - amount, 0, max_hp)
	
	if hud:
		hud.atualizar_vida_boss(hp, max_hp)

	if hp <= max_hp / 2 and not phase2:
		phase2 = true
	if hp <= 0:
		die()

func die():
	queue_free()
