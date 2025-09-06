extends TextureRect

# --- Controles de Animação (Ajuste no Inspetor!) ---
@export_group("Movimento Vertical")
@export var move_vertical: bool = true
@export var move_speed: float = 1.0
@export var move_amplitude: float = 10.0 # O quão longe ele se move para cima/baixo

@export_group("Rotação")
@export var rotacionar: bool = true
@export var rotation_speed: float = 0.8
@export var rotation_amplitude: float = 15.0 # O ângulo máximo que ele gira (em graus)

# Variáveis internas
var _tempo_passado: float = 0.0
var _posicao_original: Vector2

func _ready():
	# Guarda a posição inicial para calcular a flutuação
	_posicao_original = position
	# Adiciona um valor aleatório para que cada holofote se mova fora de sincronia
	_tempo_passado = randf() * 100.0

func _process(delta: float):
	_tempo_passado += delta
	
	# --- Lógica do Movimento Vertical ---
	if move_vertical:
		var nova_posicao_y = _posicao_original.y + sin(_tempo_passado * move_speed) * move_amplitude
		position.y = nova_posicao_y
	
	# --- Lógica da Rotação ---
	if rotacionar:
		# A função sin() cria uma onda suave entre -1 e 1, perfeita para um balanço
		rotation_degrees = sin(_tempo_passado * rotation_speed) * rotation_amplitude
