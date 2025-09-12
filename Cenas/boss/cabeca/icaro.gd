extends Node2D

const FalasScene = preload("res://Cenas/boss/cabeca/icaro_falas.tscn")

var falas: Array[String] = [
	"ROTAÇÃO, TRANSLAÇÃO e ESCALA!",
	"VOU TE ROTACIONAR",
	"AHAHAHAHHAHAHAHAHA",
	"RASTERIZAR? EU VOU É TE REPROVAR",
	"TA DANDO PRA VER AI DE TRAS",
	"Cuidado..."
]

@onready var spawn_timer: Timer = $SpawnTimer
@onready var animation_player: AnimationPlayer = $AnimationPlayer
@onready var animated_sprite: AnimatedSprite2D = $FloatingAnimation

func _ready():
	spawn_timer.timeout.connect(_on_spawn_timer_timeout)

func _on_spawn_timer_timeout():
	var text_instance = FalasScene.instantiate()

	text_instance.get_node("Label").text = falas.pick_random()

	var spawn_radius = randf_range(80, 150)
	var random_angle = randf_range(0, TAU)
	var offset = Vector2.RIGHT.rotated(random_angle) * spawn_radius
	
	text_instance.global_position = animated_sprite.global_position + offset
	
	get_parent().add_child(text_instance)
