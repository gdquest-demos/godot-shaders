extends TextureRect

export var direction_provider_path := NodePath()

onready var direction_provider: Node = get_node(direction_provider_path)


func _ready() -> void:
	if direction_provider:
		direction_provider.connect("speeding_up", self, "_on_speeding_up")


func _on_speeding_up(percentage_of_max: float) -> void:
	self_modulate.a = percentage_of_max
