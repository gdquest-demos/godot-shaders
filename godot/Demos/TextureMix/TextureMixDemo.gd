extends Spatial

onready var _animation_player: AnimationPlayer = $AnimationPlayer


func _unhandled_input(event: InputEvent) -> void:
	if event.is_action_pressed("ui_accept"):
		_animation_player.play("show-mix")
