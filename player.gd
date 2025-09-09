extends CharacterBody2D

@export var speed: float = 300.0
@export var acceleration: float = 1500.0 
@export var friction: float = 1500.0
@export var vidas_maximas: int = 3 #Vida máxima
var vidas: int = vidas_maximas #Vida atual
var hud : Node
@onready var placeholder: ColorRect = $ColorRect
var esta_morto : bool = false

func _physics_process(delta: float) -> void:
	if esta_morto:
		return
	var input_vector := Vector2.ZERO
	input_vector.x = Input.get_action_strength("move_right") - Input.get_action_strength("move_left")
	input_vector.y = Input.get_action_strength("move_down") - Input.get_action_strength("move_up")

	input_vector = input_vector.normalized()


	if input_vector != Vector2.ZERO:
		velocity = velocity.move_toward(input_vector * speed, acceleration * delta)
		_sprite_andando()
	else:
		velocity = velocity.move_toward(Vector2.ZERO, friction * delta)
		_sprite_parado()
	move_and_slide()
	
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
	var overlay = preload("res://Cenas/game_over.tscn").instantiate()
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
	placeholder.color = Color(1, 1, 1, 1) #Azul ele esta parado

func _sprite_andando() -> void:
	placeholder.color = Color(0, 1, 0, 1) #Verde esta andando

func _sprite_morto() -> void:
	placeholder.color = Color(1, 0, 0, 1) #Vermelho esta morto
