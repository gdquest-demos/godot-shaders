extends Sprite

onready var anim_player: AnimationPlayer = $AnimationPlayer


func _unhandled_input(event: InputEvent) -> void:
	if event.is_action_pressed("ui_accept") and not anim_player.is_playing():
		anim_player.play("scroll")
