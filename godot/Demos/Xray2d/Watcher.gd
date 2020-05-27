tool
extends Node2D


func _ready() -> void:
	if not Engine.editor_hint:
		$AnimationPlayer.play("sweep")


func _draw() -> void:
	draw_circle(Vector2.ZERO, 15, Color.skyblue)
	draw_line(Vector2.ZERO, Vector2.RIGHT * 30, Color.crimson, 5)
