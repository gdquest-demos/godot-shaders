tool
extends Node2D

var size := Vector2.ONE
var color := Color.white

onready var tween := $Tween

func _draw() -> void:
	draw_rect(Rect2(-size/2, size), color, true)


func do_scale_down(delay: float) -> void:
	tween.interpolate_method(self, "_do_scale_down_update", size, Vector2(size.x, 0), 0.15, 0, 2, delay)
	tween.start()
	yield(tween, "tween_all_completed")
	queue_free()


func _do_scale_down_update(value: Vector2) -> void:
	size = value
	update()
