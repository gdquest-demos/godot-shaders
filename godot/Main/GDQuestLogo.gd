extends TextureButton

const COLOR_PRESSED := Color(0.84611, 0.784345, 0.902344)

func _ready() -> void:
	connect("pressed", self, "open_gdquest_website")
	connect("button_down", self, "_toggle_shade", [true])
	connect("button_up", self, "_toggle_shade", [false])


func open_gdquest_website() -> void:
	OS.shell_open("http://gdquest.com/")


func _toggle_shade(is_down: bool) -> void:
	modulate = COLOR_PRESSED if is_down else Color.white
