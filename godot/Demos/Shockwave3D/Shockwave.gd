extends Spatial

export var shockwave_material: ShaderMaterial
onready var tween := $Tween


func _ready() -> void:
	for child in get_children():
		if child is MeshInstance:
			child.set_surface_material(0, shockwave_material)


func _unhandled_input(event: InputEvent) -> void:
	if event.is_action_pressed("ui_accept"):
		tween.interpolate_method(self, "_Tween_shockwave_percentage", 0, 1, 2.0)
		tween.start()
		yield(tween, "tween_all_completed")
		_Tween_shockwave_percentage(0.0)


func _Tween_shockwave_percentage(value: float) -> void:
	shockwave_material.set_shader_param("shockwave_percentage", value)
