extends RigidBody

var _thrown := false
onready var _animation_player: AnimationPlayer = $ForceField/AnimationPlayer


func _ready() -> void:
	connect("body_entered", self, "_on_RigidBody_body_entered", [], CONNECT_ONESHOT)


func _unhandled_input(event: InputEvent) -> void:
	if not _thrown and event.is_action_pressed("ui_accept"):
		gravity_scale = 1
		apply_central_impulse(Vector3(0, 4, -6))
		_thrown = true

func _on_RigidBody_body_entered(body: Node) -> void:
	_animation_player.play("Expand")
