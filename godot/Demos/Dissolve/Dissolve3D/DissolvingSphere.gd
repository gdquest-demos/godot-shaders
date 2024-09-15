extends MeshInstance3D

@onready var _animation_player: AnimationPlayer = $AnimationPlayer


func _unhandled_input(event: InputEvent) -> void:
	if event.is_action_pressed("ui_accept"):
		dissolve()


func dissolve() -> void:
	_animation_player.play("Dissolve")
