extends Node3D

@export var shockwave_material: ShaderMaterial
@onready var _animation_player: AnimationPlayer = $AnimationPlayer


func _ready() -> void:
	for child in get_children():
		if child is MeshInstance3D:
			child.set_surface_override_material(0, shockwave_material)


func _unhandled_input(event: InputEvent) -> void:
	if event.is_action_pressed("ui_accept"):
		_animation_player.stop(true)
		_animation_player.play("Shockwave")
