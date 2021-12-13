tool
extends CanvasLayer

const PALLETE_COUNT := 4

onready var sprite: Sprite = $PaletteSwapSprite


func _unhandled_input(event: InputEvent) -> void:
	if event.is_action_pressed("ui_accept"):
		var index = sprite.material.get_shader_param("palette_index")
		sprite.material.set_shader_param("palette_index", posmod(index + 1, PALLETE_COUNT))
