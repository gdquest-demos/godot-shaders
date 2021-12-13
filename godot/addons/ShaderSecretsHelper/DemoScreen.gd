extends CanvasLayer
class_name DemoScreen

onready var _demo_interface: Control = $DemoInterface

func _ready() -> void:
	var translation_key: String = name.to_lower()
	_demo_interface.set_text_bbcode(tr(translation_key))
	if _demo_interface.text_bbcode == translation_key:
		print_debug(
			"Missing translation key {} for demo {}".format(
				[translation_key, name], "{}"
			)
		)
