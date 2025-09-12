extends Area2D

@export var velocidade: float = 600.0
@export var tempo_de_vida: float = 1.6
@export var cor: Color = Color(1, 1, 1)  # cor do texto
@export var dano: int = 5

var direcao: Vector2 = Vector2.RIGHT
var atirador: Node = null

@onready var rotulo: Label = $TxtEquacao

# Algumas equações/símbolos para o projétil
var equacoes := ["x²", "x³", "x*y", "√x", "∫", "Σ", "π", "Δ", "∂", "lim", "f(x)"]

func _ready() -> void:
	# texto aleatório
	rotulo.text = equacoes[randi() % equacoes.size()]
	rotulo.modulate = cor

	# rotação na direção do disparo
	rotation = direcao.angle()

	# destrói sozinho depois de um tempo
	var t := get_tree().create_timer(tempo_de_vida)
	t.timeout.connect(queue_free)

	# conectar colisão
	body_entered.connect(_quando_colidir)

func _physics_process(delta: float) -> void:
	global_position += direcao * velocidade * delta

func _quando_colidir(alvo: Node) -> void:
	if alvo == atirador:
		return
	if alvo.has_method("receber_dano"):
		alvo.receber_dano(dano)
	queue_free()
