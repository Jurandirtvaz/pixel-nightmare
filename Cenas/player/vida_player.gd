extends Node

#variaveis da vida do player
var vidas_maximas: int = 3
var vidas_atual: int = vidas_maximas
	
func resetar_vidas():
	vidas_atual = vidas_maximas
	print("Vidas resetadas para:", vidas_atual)

func perder_vida():
	vidas_atual -= 1
	print("Vida perdida. Vida restantes: ", vidas_atual)
	return vidas_atual
