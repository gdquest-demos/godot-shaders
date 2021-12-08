tool
extends Node2D


func _draw() -> void:
	draw_circle(Vector2.ZERO, 15, Color.skyblue)
	draw_line(Vector2.ZERO, Vector2.RIGHT * 30, Color.crimson, 5)
