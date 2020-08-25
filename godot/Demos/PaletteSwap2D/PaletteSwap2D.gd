tool
extends Control

export (int) var index: = 0 setget set_index
var palette_count: = 4
onready var sprite:= $Sprite_code_shader

func set_index(value:int)->void:
	index = value % palette_count								#loop index between palette count
	sprite.material.set_shader_param("palette_index", index)	#Set shader param to the value

func _unhandled_input(event:InputEvent)->void:
	if event.is_pressed():										#Any button
		set_index(index + 1)
