tool
extends Node2D


func _draw() -> void:
	draw_polygon([Vector2.ZERO, Vector2(2000, 500), Vector2(2000, -500)], [Color.white])
