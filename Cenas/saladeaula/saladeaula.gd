extends Node2D

@onready var fade_transition = $FadeTransition
@onready var animation_player_fade = $FadeTransition/AnimationPlayer
@onready var cutscene_sprite: AnimatedSprite2D = $CutsceneSprite
@onready var dialogue_ui: CanvasLayer = $CaixaDialogo

var dialogo_name: String = "Icaro"
var dialogo_inicio: Array[String] = [
	"Bem a primeira questão nos temos que a projeção ortográfica...",
	"Então vocês vão aplicar essa formula...",
	"Muito cuidado pra não errar as definições...",
	"Todo quesito vale 2,5..."
]

func _ready():
	dialogue_ui.dialogue_finished.connect(_on_dialogue_finished)
	cutscene_sprite.animation_finished.connect(_on_animation_finished)
	animation_player_fade.animation_finished.connect(_on_fade_finished)
	var cutscene_a_tocar = GameState.proxima_cutscene
	match cutscene_a_tocar:
		"inicio":
			_tocar_cutscene_inicio()

func _tocar_cutscene_inicio():
	print("Iniciando a cutscene de início...")
	
	dialogue_ui.start_dialogue(dialogo_inicio, dialogo_name)
	cutscene_sprite.play("player_dormindo_inicio")

func _on_animation_finished():
	if cutscene_sprite.animation == "player_dormindo_inicio":
		print("Animação de início terminou, começando o loop.")
		cutscene_sprite.play("player_dormindo_loop")
		
	if cutscene_sprite.animation == "player_dormindo":
		print("Animação terminada indo pra bossfight")
		animation_player_fade.play("fade_out")

func _on_dialogue_finished():
	cutscene_sprite.play("player_dormindo")
	

func _on_fade_finished(anim_name):
	if anim_name == "fade_out":
		print("Fade concluído. Carregando cena do chefe!")
	get_tree().change_scene_to_file("res://Cenas/saladeaula/limbo/limbo.tscn")
	
