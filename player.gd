extends CharacterBody2D

@export var speed: float = 300.0
@export var acceleration: float = 1500.0 
@export var friction: float = 1500.0
@export var max_hp: int = 3 #Vida máxima
var hp: int = max_hp #Vida atual

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
	
func tomar_dano(amount: int) -> void:
	hp -= amount
	if hp < 0 :
		hp = 0
	print("HP atual:", hp)
	if hp == 0:
		morrer()

func morrer() -> void:
	velocity = Vector2.ZERO
	print("GAME OVER")
	#Ainda vou implementar:         (NETO)
	#Adicionar uma troca de cena
	#Fazer uma animacao de morte
	#Mostrar um hud de game over
