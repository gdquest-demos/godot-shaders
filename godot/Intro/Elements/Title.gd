extends Label

onready var _tween: Tween = $Tween

func change_title(title: String) -> void:
	_tween.interpolate_property(self, "modulate", Color.white, Color.transparent, 0.15)
	_tween.start()
	yield(_tween, "tween_all_completed")
	text = title
	_tween.interpolate_property(self, "modulate", Color.transparent, Color.white, 0.15)
	_tween.start()
