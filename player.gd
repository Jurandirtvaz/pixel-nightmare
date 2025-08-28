extends CharacterBody2D

@export var speed = 150.0          # Velocidade
@export var jump_velocity = -300.0 # Força do pulo
@export var acceleration = 800.0   # Quão rápido o personagem atinge a velocidade máxima
@export var friction = 1000.0      # Quão rápido o personagem para ao soltar a tecla de movimento

var gravity = ProjectSettings.get_setting("physics/2d/default_gravity")

func _physics_process(delta):
	if not is_on_floor():
		velocity.y += gravity * delta

	if Input.is_action_just_pressed("jump") and is_on_floor():
		velocity.y = jump_velocity
		
	var direction = Input.get_axis("move_left", "move_right")

	if direction:
		velocity.x = move_toward(velocity.x, direction * speed, acceleration * delta)
	else:
		velocity.x = move_toward(velocity.x, 0, friction * delta)

	move_and_slide()
