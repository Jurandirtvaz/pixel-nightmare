extends Node2D


@onready var animation_player: AnimationPlayer = $AnimationPlayer
@onready var sprite: AnimatedSprite2D = $FallingPlayerSprite

func _ready():
	animation_player.animation_finished.connect(_on_fall_animation_finished)
	animation_player.play("fall_animation")
	

func _on_fall_animation_finished(anim_name):
	if anim_name == "fall_animation":
		print("Queda no limbo terminada. Teleportando para a luta contra o chefe!")
		get_tree().change_scene_to_file("res://Cenas/bossfight/cenario.tscn")
