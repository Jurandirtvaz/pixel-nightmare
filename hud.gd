extends CanvasLayer
@onready var vidas = [ 
	$"UI/Vidas/Vida1",
	$"UI/Vidas/Vida2",
	$"UI/Vidas/Vida3"
]

var vidas_atuais: int = 3

func _ready() -> void:
	atualizar_vidas(vidas_atuais)

func atualizar_vidas(valor:int) -> void:
	vidas_atuais = clamp(valor, 0, vidas.size())
	for i in range(vidas.size()):
		if i < vidas_atuais:
			#vida ativa
			vidas[i].modulate = Color(1, 1, 1, 1)
		else:
			#Vida perdida
			vidas[i].modulate = Color(0.3, 0.3, 0.3, 0.6)
	print("HUD atualizando para:", vidas_atuais)
	
#Efeito para vida piscar quando tomar dano
func piscar_vida(indice:int) -> void:
	if indice < 0 or indice >= vidas.size():
		return
	var no = vidas[indice]
	var original = no.modulate
	no.modulate = Color(1, 0.2, 0.2, 1)
	await get_tree().create_timer(0.08).timeout
	no.modulate = original
