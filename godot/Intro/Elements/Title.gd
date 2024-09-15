extends Label

@onready var _tween: Tween = $Tween

func change_title(title: String) -> void:
	_tween.interpolate_property(self, "modulate", Color.WHITE, Color.TRANSPARENT, 0.15)
	_tween.start()
	await _tween.tween_all_completed
	text = title
	_tween.interpolate_property(self, "modulate", Color.TRANSPARENT, Color.WHITE, 0.15)
	_tween.start()
