extends Control

@onready var Pergunta = $Label
@onready var botao1 = $Button
@onready var botao2 = $Button2
@onready var botao3 = $Button3
@onready var botao4 = $Button4

var possiveisPerguntas = []
var perguntaEscolhida
var resposta_correta: int

func _ready():
	# Carrega as perguntas
	possiveisPerguntas = read_json("res://Cenas/perguntafinal/Perguntas.json")
	if possiveisPerguntas:
		exibir_pergunta()

func exibir_pergunta():
	botao1.show()
	botao2.show()
	botao3.show()
	botao4.show()
	# Escolhe uma pergunta aleatória
	var indice_aleatorio = randi() % possiveisPerguntas.size()
	perguntaEscolhida = possiveisPerguntas[indice_aleatorio]
	
	Pergunta.text = perguntaEscolhida["pergunta"]
	
	botao1.text = perguntaEscolhida["opcoes"][0]
	botao2.text = perguntaEscolhida["opcoes"][1]
	botao3.text = perguntaEscolhida["opcoes"][2]
	botao4.text = perguntaEscolhida["opcoes"][3]
	resposta_correta = perguntaEscolhida["opcaocorreta"]

func verificar_resposta(botao_index: int):
	if botao_index == resposta_correta:
		print("Resposta correta!")
	else:
		print("Resposta errada! A correta era: ", perguntaEscolhida["opcoes"][resposta_correta])
	exibir_pergunta()
	
func _on_button_pressed():
	verificar_resposta(0)
func _on_button_2_pressed():
	verificar_resposta(1)
func _on_button_3_pressed():
	verificar_resposta(2)
func _on_button_4_pressed():
	verificar_resposta(3)
	
func read_json(arquivo):
	var file = FileAccess.open(arquivo, FileAccess.READ)
	var content = file.get_as_text()
	file.close()
	var json = JSON.new()
	var error = json.parse(content)
	if error == OK:
		print(json.get_data())
		return json.get_data()
	else:
		print("Erro JSON: ", json.get_error_message())
		return null
	
