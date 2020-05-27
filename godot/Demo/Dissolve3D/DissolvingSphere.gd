extends MeshInstance

onready var tween := $Tween
onready var material := get_surface_material(0)


func _ready() -> void:
	tween.interpolate_method(
		self, "on_dissolve_param", 0, 1, 3.5, Tween.TRANS_LINEAR, Tween.EASE_IN_OUT
	)
	tween.start()
	yield(tween, "tween_all_completed")
	visible = false


func on_dissolve_param(value: float) -> void:
	material.set_shader_param("dissolve_amount", value)
