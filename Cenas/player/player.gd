extends CharacterBody2D
#Movimento
@export var speed: float = 300.0
@export var acceleration: float = 1500.0 
@export var friction: float = 1500.0

var hud : Node

#Invencibilidade 
@export var t_invencivel_inicial: float = 1.5
var invencivel: bool = false
var t_invencivel_restante: float = 0.0
var tween_invencibilidade: Tween

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
@onready var collision_shape: CollisionShape2D = $CollisionShape2D
@onready var placeholder: ColorRect = $ColorRect
var esta_morto : bool = false
var esta_imune : bool = false
var travado_por_pergunta: bool = false

func _physics_process(delta: float) -> void:
	if esta_morto or travado_por_pergunta:
		return
	
	if invencivel: 
		t_invencivel_restante -= delta
		if t_invencivel_restante <= 0:
			finalizar_invencibilidade()
	
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
	if Input.is_action_pressed("attack") and not travado_por_pergunta:
		_atirar()

func tomar_dano() -> void:
	if invencivel or esta_morto or esta_imune:
		return
	
	if VidaPlayer.vidas_atual <= 0:
		return
	VidaPlayer.perder_vida()
	
	#Atualizar os quadradinhos de vida
	if hud:
		hud.atualizar_vidas(VidaPlayer.vidas_atual)
		hud.piscar_vida(VidaPlayer.vidas_atual)
	print("Vidas do player:", VidaPlayer.vidas_atual)
	
	#Fica invencivel apos tomar dano
	ativar_invencibilidade(1.0)
	
	if VidaPlayer.vidas_atual == 0:
		await get_tree().create_timer(0.12).timeout
		morrer()

func morrer() -> void:
	esta_morto = true
	velocity = Vector2.ZERO
	_sprite_morto()
	print("GAME OVER")
	
	finalizar_invencibilidade()
	
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
	
	if hud:
		hud.atualizar_vidas(VidaPlayer.vidas_atual)
	
	ativar_invencibilidade(t_invencivel_inicial)

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

func ativar_invencibilidade(tempo: float) -> void:
	invencivel = true
	t_invencivel_restante = tempo
	
	# Desativa a colisão
	if collision_shape:
		collision_shape.set_deferred("disabled", true)
	
	# Faz o player piscar
	if tween_invencibilidade:
		tween_invencibilidade.kill()
	
	tween_invencibilidade = create_tween()
	tween_invencibilidade.set_loops()  # Loop infinito até ser parado
	
	# Efeito de piscar
	tween_invencibilidade.tween_property(animated_sprite, "modulate:a", 0.5, 0.1)
	tween_invencibilidade.tween_property(animated_sprite, "modulate:a", 1.0, 0.1)
	
	# Timer para finalizar a invencibilidade
	var timer = get_tree().create_timer(tempo)
	timer.connect("timeout", finalizar_invencibilidade)
		
func reativar_colisao() -> void: 
	if collision_shape and not esta_morto:
			collision_shape.disabled = false
			
func finalizar_invencibilidade() -> void:
	invencivel = false
	
	# Para o efeito de piscar
	if tween_invencibilidade:
		tween_invencibilidade.kill()
	
	# Restaura a opacidade normal
	if animated_sprite:
		animated_sprite.modulate.a = 1.0
	
	# Reativa a colisão se não estiver morto
	if collision_shape and not esta_morto:
		collision_shape.disabled = false

func set_imunidade(imune: bool):
	esta_imune = imune

func travar_por_pergunta():
	travado_por_pergunta = true
	velocity = Vector2.ZERO
	if animated_sprite: 
		animated_sprite.stop()
		
func destravar_por_pergunta():
	travado_por_pergunta = false
	if animated_sprite: 
		_sprite_parado()
