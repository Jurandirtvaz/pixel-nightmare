extends CanvasLayer

func _ready() -> void:
	#Para que o overlay funcione com o jogo pausado
	process_mode = Node.PROCESS_MODE_WHEN_PAUSED

func _unhandled_input(event: InputEvent) -> void:
	if event.is_action_pressed("restart"):
		#reinicia o jogo
		get_tree().paused = false
		get_tree().reload_current_scene()
	elif event.is_action_pressed("ui_quit"):
		#fecha o jogo
		get_tree().quit()
