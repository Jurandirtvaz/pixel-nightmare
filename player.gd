extends CharacterBody2D

@export var speed = 150.0          # Velocidade
@export var acceleration = 800.0   # Quão rápido atinge a velocidade máxima
@export var friction = 1000.0      # Quão rápido para ao soltar a tecla

func _physics_process(delta):
	# Movimento horizontal
	var direction_x = Input.get_axis("move_left", "move_right")
	if direction_x != 0:
		velocity.x = move_toward(velocity.x, direction_x * speed, acceleration * delta)
	else:
		velocity.x = move_toward(velocity.x, 0, friction * delta)
	
	# Movimento vertical
	var direction_y = Input.get_axis("move_up", "move_down")
	if direction_y != 0:
		velocity.y = move_toward(velocity.y, direction_y * speed, acceleration * delta)
	else:
		velocity.y = move_toward(velocity.y, 0, friction * delta)

	move_and_slide()
