extends Control

@export var game_scene: PackedScene

func _ready():
	$"Iniciar Jogo".pressed.connect(_on_start_button_pressed)
	
	Input.set_mouse_mode(Input.MOUSE_MODE_VISIBLE)

func _on_start_button_pressed():
	print("Iniciando o jogo!")
	
	if game_scene:
		get_tree().change_scene_to_packed(game_scene)
	else:
		push_error("A cena do jogo (game_scene) não foi definida no Inspetor!")
