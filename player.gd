extends CharacterBody2D

@export var speed: float = 300.0
@export var acceleration: float = 1500.0 
@export var friction: float = 1500.0
@export var vidas_maximas: int = 3 #Vida máxima
var vidas: int = vidas_maximas #Vida atual
var hud : Node

func _physics_process(delta: float) -> void:
	var input_vector := Vector2.ZERO
	input_vector.x = Input.get_action_strength("move_right") - Input.get_action_strength("move_left")
	input_vector.y = Input.get_action_strength("move_down") - Input.get_action_strength("move_up")

	input_vector = input_vector.normalized()


	if input_vector != Vector2.ZERO:
		velocity = velocity.move_toward(input_vector * speed, acceleration * delta)
	else:
		velocity = velocity.move_toward(Vector2.ZERO, friction * delta)

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
	velocity = Vector2.ZERO
	print("GAME OVER")
	await get_tree().create_timer(0.3).timeout
	get_tree().change_scene_to_file("res://Cenas/game_over.tscn")
	
#funcao para testar o dano e o hud das vidas
func _unhandled_input(event: InputEvent) -> void:
	if event.is_action_pressed("ui_accept"):
		tomar_dano()
		
func _ready() -> void:
	hud = get_tree().get_first_node_in_group("hud")
	print("HUD encontrado? ", hud != null)
