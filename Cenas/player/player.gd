extends CharacterBody2D
#Movimento
@export var speed: float = 300.0
@export var acceleration: float = 1500.0 
@export var friction: float = 1500.0

#Vidas / Hud
@export var vidas_maximas: int = 3 #Vida máxima
var vidas: int = vidas_maximas #Vida atual
var hud : Node

#Ataque
@export var dano_ataque: int = 5
@export var reload: float = 0.8
@export var travar_apos_tiro: float = 0.20 #tempo que o player vai ficar parado
var movimento_travado: bool = false
var pode_atirar: bool = true
var ultima_direcao: Vector2 = Vector2.DOWN
@onready var ponto_tiro: Node2D = $PontodoTiro
@onready var projetil = preload("res://Cenas/player/ataque/tiro_equacional.tscn")

@onready var animated_sprite: AnimatedSprite2D = $AnimatedSprite2D

@onready var placeholder: ColorRect = $ColorRect
var esta_morto : bool = false

func _physics_process(delta: float) -> void:
	if esta_morto:
		return
	
	if movimento_travado:
		velocity = velocity.move_toward(Vector2.ZERO, friction * delta)
		move_and_slide()
	
	var input_vector := Vector2.ZERO
	input_vector.x = Input.get_action_strength("move_right") - Input.get_action_strength("move_left")
	input_vector.y = Input.get_action_strength("move_down") - Input.get_action_strength("move_up")

	#Movimento
	input_vector = input_vector.normalized()
	if input_vector != Vector2.ZERO:
		ultima_direcao = input_vector
		velocity = velocity.move_toward(input_vector * speed, acceleration * delta)
		_sprite_andando()
	else:
		velocity = velocity.move_toward(Vector2.ZERO, friction * delta)
		_sprite_parado()
	move_and_slide()
	#Ataque
	if Input.is_action_pressed("attack"):
		_atirar()

func tomar_dano() -> void:
	if vidas <= 0:
		return
	vidas -= 1
	#Atualizar os quadradinhos de vida
	if hud:
		hud.atualizar_vidas(vidas)
		hud.piscar_vida(vidas)
	print("Vidas do player:", vidas)
	
	if vidas == 0:
		await get_tree().create_timer(0.12).timeout
		morrer()

func morrer() -> void:
	esta_morto = true
	velocity = Vector2.ZERO
	_sprite_morto()
	print("GAME OVER")
	await get_tree().create_timer(0.3).timeout
	
	#Adicionando o game-over como overlay
	var overlay = preload("res://Cenas/gameover/game_over.tscn").instantiate()
	get_tree().current_scene.add_child(overlay)
	get_tree().paused = true
	
#funcao para testar o dano e o hud das vidas
func _unhandled_input(event: InputEvent) -> void:
	if event.is_action_pressed("teste_dano"):
		tomar_dano()
		
func _ready() -> void:
	hud = get_tree().get_first_node_in_group("hud")
	print("HUD encontrado? ", hud != null)

func _sprite_parado() -> void:
	if ultima_direcao.y > 0:
		animated_sprite.play("idle_down")
	elif ultima_direcao.y < 0:
		animated_sprite.play("idle_up")
	elif ultima_direcao.x < 0:
		animated_sprite.play("idle_left")
	elif ultima_direcao.x > 0:
		animated_sprite.play("idle_right")

func _sprite_andando() -> void:
	if ultima_direcao.y > 0:
		animated_sprite.play("walk_down")
	elif ultima_direcao.y < 0:
		animated_sprite.play("walk_up")
	elif ultima_direcao.x < 0:
		animated_sprite.play("walk_left")
	elif ultima_direcao.x > 0:
		animated_sprite.play("walk_right")

func _sprite_morto() -> void:
	placeholder.color = Color(1, 0, 0, 1) #Vermelho esta morto

func _atirar() -> void:
	if not pode_atirar or movimento_travado:
		return
	pode_atirar = false
	movimento_travado = true
	velocity = Vector2.ZERO
	
	var proj = projetil.instantiate()
	proj.global_position = ponto_tiro.global_position
	#Ajuste para ele atirar pela direcao do mouse
	var dir := get_global_mouse_position() - ponto_tiro.global_position
	if dir.length() < 0.001:
		dir = Vector2.RIGHT #fallback
	else: 
		dir = dir.normalized()
		
	proj.direcao = dir
	proj.dano = dano_ataque
	proj.atirador = self
	get_parent().add_child(proj)
	
	var t_reload := get_tree().create_timer(reload)
	var t_travado := get_tree().create_timer(travar_apos_tiro) 
	
	await t_travado.timeout
	movimento_travado = false
	
	await t_reload.timeout
	pode_atirar = true
