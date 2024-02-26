@tool
# ANCHOR: setup
extends Particles

@export var character_node := NodePath()
# END: setup
@onready var _animator: AnimationPlayer = $AnimationPlayer
@onready var _area: Area3D = $Area3D

func _ready() -> void:
	_area.connect("body_entered", Callable(self, "on_area_body_entered").bind(true))
	_area.connect("body_exited", Callable(self, "on_area_body_entered").bind(false))
	
func on_area_body_entered(body: Node, is_entering: bool) -> void:
	if body is RigidBody3D:
		_animator.play("show") if is_entering else _animator.play_backwards("show")
# ANCHOR: process
func _process(_delta: float) -> void:
	process_material.set_shader_parameter("character_position", get_node(character_node).global_transform.origin)
# END: process
