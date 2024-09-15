extends TextureButton

const COLOR_PRESSED := Color(0.84611, 0.784345, 0.902344)

func _ready() -> void:
	connect("pressed", Callable(self, "open_gdquest_website"))
	connect("button_down", Callable(self, "_toggle_shade").bind(true))
	connect("button_up", Callable(self, "_toggle_shade").bind(false))


func open_gdquest_website() -> void:
	OS.shell_open("http://gdquest.com/")


func _toggle_shade(is_down: bool) -> void:
	modulate = COLOR_PRESSED if is_down else Color.WHITE
