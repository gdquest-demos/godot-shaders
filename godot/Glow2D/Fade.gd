extends Sprite

onready var tween := $Tween


func _ready() -> void:
	tween.interpolate_method(self, "fade", 3.0, 0.0, 2.0, Tween.TRANS_LINEAR, Tween.EASE_IN)
	tween.interpolate_method(self, "fade", 0.0, 3.0, 5.0, Tween.TRANS_LINEAR, Tween.EASE_OUT, 2.0)
	tween.start()


func fade(value: float) -> void:
	material.set_shader_param("alpha_falloff_back", value)
