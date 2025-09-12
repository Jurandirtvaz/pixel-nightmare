extends Node2D

@onready var label: Label = $Label

func _ready():
	$AnimationPlayer.play("fade_and_float")
