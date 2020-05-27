extends Label


var color := Color.white

onready var tween := $Tween


func change_title(title: String) -> void:
	tween.interpolate_property(self, "modulate", color, Color.transparent, 0.15)
	tween.start()
	yield(tween, "tween_all_completed")
	text = title
	tween.interpolate_property(self, "modulate", Color.transparent, color, 0.15)
	tween.start()
