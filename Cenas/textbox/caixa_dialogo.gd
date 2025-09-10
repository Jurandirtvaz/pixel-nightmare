extends CanvasLayer

signal dialogue_finished # Sinal para avisar quando o diálogo terminar

@onready var text_label: RichTextLabel = $TextBox/RichTextLabel
@onready var typewriter_timer: Timer = $TypewriterTimer
@onready var next_indicator: TextureRect = $TextBox/Proximo
@onready var name_box: Panel = $NameBox
@onready var name_label: Label = $NameBox/NameLabel

@export var typing_speed: float = 0.05 # Segundos por caractere

var messages: Array[String] = [] # Fila de mensagens para exibir
var current_message_index: int = 0
var is_typing: bool = false

func _ready() -> void:
	hide()
	typewriter_timer.timeout.connect(_on_typewriter_timer_timeout)

# Função principal para iniciar o diálogo
func start_dialogue(message_queue: Array[String], speaker_name: String = "") -> void:
	if message_queue.is_empty():
		return
	if speaker_name == "":
		name_box.hide()
	else:
		name_label.text = speaker_name
		name_box.show()
	
	messages = message_queue
	current_message_index = 0
	show() # Mostra a caixa de diálogo
	_show_current_message()

# Função chamada quando o jogador pressiona o botão de ação
func _input(event: InputEvent) -> void:
	# Só processa o input se a caixa de diálogo estiver visível
	if not is_visible():
		return

	if event.is_action_pressed("ui_accept"):
		if is_typing:
			# Se o texto está aparecendo, revela tudo de uma vez
			_finish_typing()
		else:
			# Se o texto já terminou, avança para a próxima mensagem
			_next_message()

# Mostra a mensagem atual com o efeito typewriter
func _show_current_message() -> void:
	text_label.text = messages[current_message_index]
	text_label.visible_characters = 0 # Esconde todos os caracteres
	is_typing = true
	next_indicator.hide()
	typewriter_timer.wait_time = typing_speed
	typewriter_timer.start()

# Função chamada pelo Timer a cada X segundos
func _on_typewriter_timer_timeout() -> void:
	if text_label.visible_characters < text_label.get_total_character_count():
		text_label.visible_characters += 1
	else:
		_finish_typing()

# Revela o resto da mensagem instantaneamente
func _finish_typing() -> void:
	typewriter_timer.stop()
	text_label.visible_characters = text_label.get_total_character_count()
	is_typing = false
	next_indicator.show()

# Passa para a próxima mensagem ou fecha a caixa de diálogo
func _next_message() -> void:
	current_message_index += 1
	if current_message_index < messages.size():
		_show_current_message()
	else:
		_close_dialogue()

# Fecha a caixa de diálogo e emite o sinal
func _close_dialogue() -> void:
	name_box.hide()
	hide()
	messages.clear()
	current_message_index = 0
	dialogue_finished.emit()
