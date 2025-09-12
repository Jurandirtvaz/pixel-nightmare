extends Node2D

@onready var fade_transition = $FadeTransition
@onready var animation_player_fade = $FadeTransition/AnimationPlayer
@onready var cutscene_sprite: AnimatedSprite2D = $CutsceneSprite
@onready var dialogue_ui: CanvasLayer = $CaixaDialogo

var dialogo_name: String = "Icaro"
var dialogo_player: String = "Aluno"
var dialogo_inicio: Array[String] = [
	"Bem a primeira questão nos temos que a projeção ortográfica...",
	"Então vocês vão aplicar essa formula...",
	"Muito cuidado pra não errar as definições...",
	"Todo quesito vale 2,5..."
]
var dialogo_final_aluno: Array[String] = [
	"Ai meu deus eu dormi!",
	"Só mais meia hora pra terminar a prova...",
	"Mas vai dar, por algum motivo eu sinto que sei a resposta!"
]
var dialogo_final_icaro: Array[String] = [
	"Minha gente só meia hora pra terminar a prova"
] 

var current_cutscene_step: String = ""


func _ready():
	dialogue_ui.dialogue_finished.connect(_on_dialogue_finished)
	cutscene_sprite.animation_finished.connect(_on_animation_finished)
	animation_player_fade.animation_finished.connect(_on_fade_finished)
	
	var cutscene_a_tocar = GameState.proxima_cutscene
	match cutscene_a_tocar:
		"inicio":
			_tocar_cutscene_inicio()
		"fim":
			_tocar_cutscene_fim()

func _tocar_cutscene_inicio():
	print("Iniciando a cutscene de início...")
	
	current_cutscene_step = "inicio_professor_falando"
	
	cutscene_sprite.play("player_dormindo_inicio")
	dialogue_ui.start_dialogue(dialogo_inicio, dialogo_name)

func _tocar_cutscene_fim():
	print("Iniciando a cutscene de fim...")
	
	current_cutscene_step = "fim_icaro_falando"
	cutscene_sprite.play("player_acordando_inicio")
	
	dialogue_ui.start_dialogue(dialogo_final_icaro, dialogo_name)

func _on_dialogue_finished():
	match current_cutscene_step:
		
		"inicio_professor_falando":
			print("Diálogo de início terminou. Indo para o limbo...")
			# O diálogo acabou, começar a animação de dormir
			current_cutscene_step = "transicao_para_luta"
			cutscene_sprite.play("player_dormindo")
			
		"fim_icaro_falando":
			print("Diálogo do Icaro no fim terminou. Player vai acordar e falar.")
			# O professor terminou de falar, agora o player acorda
			cutscene_sprite.play("player_acordando")
			
		"fim_aluno_falando":
			print("Diálogo do aluno terminou. Fim do jogo.")
			# O diálogo do aluno terminou, a cutscene acabou
			current_cutscene_step = "finalizado"
			animation_player_fade.play("fade_out")
			


func _on_animation_finished():
	var current_anim = cutscene_sprite.animation
	
	if current_anim == "player_dormindo_inicio":
		cutscene_sprite.play("player_dormindo_loop")
	
	elif current_anim == "player_acordando_inicio":
		cutscene_sprite.play("player_acordando_loop")
	
	elif current_anim == "player_dormindo":
		# A animação de dormir terminou, ir pra transição de luta
		animation_player_fade.play("fade_out")
	
	elif current_anim == "player_acordando":
		# A animação de acordar terminou, começar o dialogo do aluno
		dialogue_ui.start_dialogue(dialogo_final_aluno, dialogo_player)
		current_cutscene_step = "fim_aluno_falando"


func _on_fade_finished(anim_name):
	if anim_name == "fade_out":
		if current_cutscene_step == "transicao_para_luta":
			print("Fade concluído. Carregando cena do limbo!")
			get_tree().change_scene_to_file("res://Cenas/saladeaula/limbo/limbo.tscn")
	if current_cutscene_step == "finalizado":
			print("Fade concluído. Carregando cena do final!")
			get_tree().change_scene_to_file("res://Cenas/final/fim.tscn")
