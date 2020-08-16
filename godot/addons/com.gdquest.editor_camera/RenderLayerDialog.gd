tool
extends WindowDialog


signal flag_changed(value)

onready var layer_grid := $CenterContainer/VBoxContainer/LayerGrid


func _on_OKButton_pressed() -> void:
	emit_signal("flag_changed", layer_grid.value)
	hide()


func _on_CancelButton_pressed() -> void:
	hide()
