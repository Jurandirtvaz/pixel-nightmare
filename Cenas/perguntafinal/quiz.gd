extends CanvasLayer

@onready var pergunta_label = $Panel/Label
@onready var botao1 = $Panel/Button1
@onready var botao2 = $Panel/Button2
@onready var botao3 = $Panel/Button3
@onready var botao4 = $Panel/Button4

var boss: Node = null
var pergunta_atual: Dictionary


func _ready():
	add_to_group("quiz")
	carregar_perguntas()
	exibir_pergunta_aleatoria()
	animar_entrada()
	proteger_player()

func carregar_perguntas():
	var perguntas = read_json("res://Cenas/perguntafinal/Perguntas.json")
	pergunta_atual = perguntas[randi_range(0, 2)]
	print("Pergunta carregada: ", pergunta_atual["pergunta"])
		

func exibir_pergunta_aleatoria():
	pergunta_label.text = pergunta_atual["pergunta"]
	botao1.text = pergunta_atual["opcoes"][0]
	botao2.text = pergunta_atual["opcoes"][1]
	botao3.text = pergunta_atual["opcoes"][2]
	botao4.text = pergunta_atual["opcoes"][3]

func verificar_resposta(indice: int):
	if indice == pergunta_atual["opcaocorreta"]:
		acerto()
	else:
		erro()

func acerto():
	remover_protecao_player()
	if boss:
		boss.morrer_definitivamente()
	queue_free()

func erro():
	remover_protecao_player()
	if boss:
		boss.reviver(0.3)  
	queue_free()

func read_json(arquivo):
	if not FileAccess.file_exists(arquivo):
		print("Arquivo não encontrado: ", arquivo)
		return []
	
	var file = FileAccess.open(arquivo, FileAccess.READ)
	if file == null:
		print("Erro ao abrir o arquivo: ", FileAccess.get_open_error())
		return []
	
	var text = file.get_as_text()
	file.close()
	
	var json = JSON.new()
	var parse_result = json.parse(text)
	
	if parse_result != OK:
		print("Erro ao parsear JSON: ", json.get_error_message())
		return []
	
	return json.get_data()
	
func animar_entrada():
	$Panel.scale = Vector2(0.5, 0.5)
	$Panel.modulate = Color(1, 1, 1, 0)
	
	var tween = create_tween()
	tween.set_parallel(true)
	tween.tween_property($Panel, "scale", Vector2(1, 1), 0.3).set_ease(Tween.EASE_OUT)
	tween.tween_property($Panel, "modulate", Color(1, 1, 1, 1), 0.3).set_ease(Tween.EASE_OUT)

func proteger_player():
	var player = get_tree().get_first_node_in_group("player")
	if player and player.has_method("set_imunidade"):
		player.set_imunidade(true)
		
func remover_protecao_player():
	var player = get_tree().get_first_node_in_group("player")
	if player and player.has_method("set_imunidade"):
		player.set_imunidade(false)

func _on_button_2_pressed() -> void:
	verificar_resposta(1)
func _on_button_3_pressed() -> void:
	verificar_resposta(2)
func _on_button_4_pressed() -> void:
	verificar_resposta(3)
func _on_button1_pressed() -> void:
	verificar_resposta(0)
	
