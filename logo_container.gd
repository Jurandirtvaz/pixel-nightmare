extends MarginContainer

@export var hover_amplitude: float = 8.0  # O quão alto e baixo a logo vai (em pixels)
@export var hover_speed: float = 1.5      # A velocidade do movimento

# Variáveis para controlar o movimento
var _tempo_passado: float = 0.0
var _posicao_original: Vector2

func _ready():
	_posicao_original = position

func _process(delta: float):
	_tempo_passado += delta
	
	var nova_posicao_y = _posicao_original.y + sin(_tempo_passado * hover_speed) * hover_amplitude
	
	position.y = nova_posicao_y
