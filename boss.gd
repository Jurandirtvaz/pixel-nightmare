extends CharacterBody2D

# Configurações do boss
@export var speed: float = 100
@export var max_hp: int = 200
@export var smash_cooldown: float = 3.0
@export var shoot_cooldown: float = 2.0

var hp: int
var phase2: bool = false
var player: CharacterBody2D = null
var smash_timer: Timer
var shoot_timer: Timer

func _ready():
	hp = max_hp
	# procura o player na cena (ajusta o caminho conforme teu jogo)
	player = get_tree().get_root().get_node("Node2D/Player")

	# Timer para smash
	smash_timer = Timer.new()
	smash_timer.wait_time = smash_cooldown
	smash_timer.autostart = true
	smash_timer.timeout.connect(_on_smash_timeout)
	add_child(smash_timer)

	# Timer para tiros (só começa na fase 2)
	shoot_timer = Timer.new()
	shoot_timer.wait_time = shoot_cooldown
	shoot_timer.autostart = false
	shoot_timer.timeout.connect(_on_shoot_timeout)
	add_child(shoot_timer)

func _physics_process(delta):
	if player:
		# movimento sempre em direção ao player
		var direction = (player.global_position - global_position).normalized()
		velocity = direction * speed
		move_and_slide()

func _on_smash_timeout():
	smash()

func smash():
	$AnimatedSprite2D.play("smash")
	var wave = preload("res://Shockwave.tscn").instantiate()
	wave.global_position = global_position
	get_parent().add_child(wave)

func _on_shoot_timeout():
	shoot()

func shoot():
	var bullet = preload("res://Bullet.tscn").instantiate()
	bullet.global_position = $ShootPoint.global_position
	bullet.direction = (player.global_position - $ShootPoint.global_position).normalized()
	get_parent().add_child(bullet)

func take_damage(amount):
	hp -= amount
	if hp <= max_hp/2 and not phase2:
		phase2 = true
		shoot_timer.start()
	if hp <= 0:
		die()

func die():
	queue_free()
