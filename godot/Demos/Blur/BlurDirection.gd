extends Control

@export var direction_provider_path := NodePath()
@export var blur_scale := Vector2.ONE

var direction := Vector2.ZERO

@onready var direction_provider: Node = get_node(direction_provider_path)


func _ready() -> void:
	if direction_provider:
		direction_provider.connect("speeding_up", Callable(self, "_on_speeding_up"))
		direction = Vector2.UP.rotated(deg_to_rad(direction_provider.direction_degrees))
	blur_scale = blur_scale.normalized()


func _on_speeding_up(percentage_of_max: float) -> void:
	material.set_shader_parameter("blur_scale", direction * percentage_of_max * blur_scale)
