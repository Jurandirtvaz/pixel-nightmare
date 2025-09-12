extends CharacterBody2D

@onready var animacao = $AnimatedSprite2D
@onready var punho = $Punho
@onready var atirar = $Atirar
@onready var shoot_point = $Atirar/ShootPoint

@export var speed: float = 100
@export var wait_time: float = 1.0
@export var attack_damage: int = 1
@export var max_hp: float = 100
@export var num_shots = 7

var hp: float
var phase2 = false
var hud: Node
var quiz_scene = preload("res://Cenas/perguntafinal/quiz.tscn")
var esta_morto = false

var player: CharacterBody2D = null
var target_position: Vector2
var moving: bool = false
var state_timer: Timer

func _ready():
	animacao.play()
	punho.hide()
	atirar.hide()
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
	if moving and player and not esta_morto:
		var dir = (target_position - global_position).normalized()
		velocity = dir * speed
		move_and_slide()

		if global_position.distance_to(target_position) < 10:
			velocity = Vector2.ZERO
			moving = false
			attack()
			state_timer.start(wait_time)

func _on_state_timer_timeout():
	if player and not esta_morto:
		_go_to_player()

func _go_to_player():
	if player and not esta_morto:
		target_position = player.global_position
		moving = true

func _on_node_added(node):
	if node.is_in_group("player"):
		player = node
		_go_to_player()
		get_tree().disconnect("node_added", Callable(self, "_on_node_added"))

# ======================
# ATAQUES COM ANIMAÇÕES
# ======================
func attack():
	# Esconde o sprite principal e mostra o punho
	animacao.hide()
	punho.show()
	atirar.hide()
	punho.position = Vector2.ZERO
	punho.scale = Vector2(1, 1)
	
	# Guarda a posição original
	var posicao_original = punho.position
	var posicao_alto = posicao_original + Vector2(0, -120)
	
	# Animação de subida rápida
	var tween_subida = create_tween()
	tween_subida.tween_property(punho, "position", posicao_alto, 0.2).set_ease(Tween.EASE_OUT)
	
	# Quando terminar a subida, inicia a descida
	tween_subida.finished.connect(_iniciar_descida.bind(posicao_original))

func _iniciar_descida(posicao_original):
	# Animação de descida com impacto
	var tween_descida = create_tween()
	tween_descida.tween_property(punho, "position", posicao_original, 0.15).set_ease(Tween.EASE_IN)
	
	# Quando terminar a descida, cria a onda de choque
	tween_descida.finished.connect(_criar_onda_de_choque)

func _criar_onda_de_choque():
	# Cria a onda de choque na posição do boss
	var wave_scene = preload("res://Cenas/boss/ataque/shockwave.tscn")
	var wave = wave_scene.instantiate()
	wave.global_position = global_position
	wave.attack_damage = attack_damage
	get_parent().add_child(wave)
	
	# Pequeno shake de câmera (opcional)
	_adicionar_shake_camera(0.1, 5)
	
	# Se estiver na fase 2, inicia o ataque de laser após delay
	if phase2:
		await get_tree().create_timer(0.5).timeout
		attack_laser()
	else:
		# Esconde o punho e mostra o sprite principal
		await get_tree().create_timer(0.3).timeout
		punho.hide()
		animacao.show()

func attack_laser():
	# Mostra o sprite de atirar e esconde os outros
	animacao.hide()
	punho.hide()
	atirar.show()
	
	if not player:
		# Se não tiver player, volta ao normal
		atirar.hide()
		animacao.show()
		return
	
	# Posiciona o sprite de atirar na mesma posição do boss
	atirar.global_position = global_position
	atirar.rotation = 0
	
	# Calcula a direção para o jogador
	var direcao = (player.global_position - atirar.global_position).normalized()
	var angulo = direcao.angle()
	
	# Animação suave para apontar para o jogador
	var tween_rotacao = create_tween()
	tween_rotacao.tween_property(atirar, "rotation", angulo, 0.4).set_ease(Tween.EASE_OUT)
	
	# Quando terminar de apontar, dispara os lasers
	tween_rotacao.finished.connect(_disparar_lasers.bind(angulo, direcao))

func _disparar_lasers(angulo_final: float, direcao_base: Vector2):
	if not player:
		# Proteção contra erros
		atirar.hide()
		animacao.show()
		return
	
	# Garante que o atirar está na rotação correta
	atirar.rotation = angulo_final
	
	var laser_scene = preload("res://Cenas/boss/ataque/bullet.tscn")
	
	# Calcula a posição do shoot_point baseado na rotação atual
	var shoot_pos = atirar.global_position + Vector2(cos(angulo_final), sin(angulo_final)) * 50
	
	# Usa a direção base que já foi calculada
	var base_dir = direcao_base
	
	var spread = deg_to_rad(90)
	var start_angle = -spread / 2
	var angle_step = spread / (num_shots - 1)
	
	for i in range(num_shots):
		var angle = start_angle + i * angle_step
		var dir = base_dir.rotated(angle)
		
		var laser = laser_scene.instantiate()
		laser.global_position = shoot_pos
		laser.direction = dir
		get_parent().add_child(laser)
		
		await get_tree().create_timer(0.20).timeout
	
	# Esconde o sprite de atirar e mostra o principal após o disparo
	await get_tree().create_timer(0.5).timeout
	atirar.hide()
	animacao.show()

# Função auxiliar para shake de câmera (opcional)
func _adicionar_shake_camera(duracao: float, intensidade: float):
	var camera = get_tree().get_first_node_in_group("camera")
	if camera and camera.has_method("shake"):
		camera.shake(duracao, intensidade)

# ======================
# SISTEMA DE QUIZ NA MORTE
# ======================
func receber_dano(amount):
	if esta_morto:
		return  # Não toma dano se já estiver morto
	
	hp = clamp(hp - amount, 0, max_hp)
	
	if hud:
		hud.atualizar_vida_boss(hp, max_hp)

	if hp <= 0 and not esta_morto:
		die()  # Agora chama die() em vez de queue_free()
	elif hp <= max_hp / 2 and not phase2:
		phase2 = true

func die():
	if esta_morto:
		return
	
	esta_morto = true
	velocity = Vector2.ZERO
	
	# Para todas as animações e movimentos
	moving = false
	if state_timer:
		state_timer.stop()
	
	# Chama a tela de quiz
	exibir_quiz()

func exibir_quiz():
	# Instancia a cena do quiz
	var quiz_instance = quiz_scene.instantiate()
	
	# Passa referência do boss para o quiz
	quiz_instance.boss = self
	
	# Adiciona o quiz na cena
	get_tree().current_scene.add_child(quiz_instance)

func reviver(percentual_vida: float):
	# Revive o chefão com percentual de vida
	esta_morto = false
	hp = max_hp * percentual_vida
	
	if hud:
		hud.atualizar_vida_boss(hp, max_hp)
	
	# Reativa o movimento
	moving = true
	_go_to_player()

func morrer_definitivamente():
	# Morte definitiva
	queue_free()
