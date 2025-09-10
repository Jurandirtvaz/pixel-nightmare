extends Area2D

# Array com as falas do NPC. Você pode editar isso no Inspetor.
@export var npc_name: String = "Coitado Nº1"
@export var dialogue_lines: Array[String] = [
	"Caramba viu materiazinha dificil do cranco",
	"Tamo é lascado",
	"Cuidado com esse caba que tá vindo ai..."
]

@export var textbox: CanvasLayer

var player_in_area: bool = false
var talking: bool = false

func _ready():
	# Conecta os sinais da própria Area2D
	body_entered.connect(_on_body_entered)
	body_exited.connect(_on_body_exited)

# Função para iniciar a conversa
func talk():
	if textbox:
		textbox.start_dialogue(dialogue_lines, npc_name)

# Detecta quando o player entra na área
func _on_body_entered(body):
	if body.is_in_group("player"): # Supondo que seu player está no grupo "player"
		player_in_area = true

# Detecta quando o player sai da área
func _on_body_exited(body):
	if body.is_in_group("player"):
		player_in_area = false

# Verifica a cada frame se o player está na área e pressiona o botão de interação
func _process(delta):
	if player_in_area and Input.is_action_just_pressed("interact") and !talking: # Crie uma ação de input "interact"
		talk()
		talking = true
