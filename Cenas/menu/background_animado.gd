extends Control

@export var scroll_speed: float = -0.35 
@onready var texture_rect = $TextureRect

func _process(delta: float):
	var material = texture_rect.material as ShaderMaterial
	
	if material:
		var current_offset = material.get_shader_parameter("scroll_offset")
		
		current_offset += scroll_speed * delta
		
		material.set_shader_parameter("scroll_offset", current_offset)
