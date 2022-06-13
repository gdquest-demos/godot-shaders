# ANCHOR: setup
extends Particles
tool

export var character_node := NodePath()
# END: setup
onready var _animator: AnimationPlayer = $AnimationPlayer
onready var _area: Area = $Area

func _ready() -> void:
	_area.connect("body_entered", self, "on_area_body_entered", [true])
	_area.connect("body_exited", self, "on_area_body_entered", [false])
	
func on_area_body_entered(body: Node, is_entering: bool) -> void:
	if body is RigidBody:
		_animator.play("show") if is_entering else _animator.play_backwards("show")
# ANCHOR: process
func _process(_delta: float) -> void:
	process_material.set_shader_param("character_position", get_node(character_node).global_transform.origin)
# END: process
