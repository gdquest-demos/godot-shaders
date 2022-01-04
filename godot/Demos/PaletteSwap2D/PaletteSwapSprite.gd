tool
extends Sprite

const PALLETE_COUNT := 4


func _unhandled_input(event: InputEvent) -> void:
	if event.is_action_pressed("ui_accept"):
		var index = material.get_shader_param("palette_index")
		material.set_shader_param("palette_index", posmod(index + 1, PALLETE_COUNT))
