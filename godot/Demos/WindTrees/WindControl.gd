tool
extends Node

export(NodePath) var intensity_slider_path
export(NodePath) var intensity_value_label_path
export(NodePath) var angle_slider_path
export(NodePath) var angle_value_label_path

export var _wind_materials := []
export(float, 0.0, 4.0, 1.0) var _wind_intensity := 0.0 setget set_wind_intensity
export(float, 0.0, 360.0, 1.0) var _wind_angle := 0.0 setget set_wind_angle

onready var _intensity_slider := get_node(intensity_slider_path)
onready var _intensity_value_label := get_node(intensity_value_label_path)
onready var _angle_slider := get_node(angle_slider_path)
onready var _angle_value_label := get_node(angle_value_label_path)

var presets = [
	["Still",   {"wind_strength" : 0.0}],
	["Calm",    {"wind_strength" : 0.10, "wind_frequency" : 1.00, "wind_speed" : 0.15}],
	["Breeze",  {"wind_strength" : 0.25, "wind_frequency" : 0.50, "wind_speed" : 0.25}],
	["Strong",  {"wind_strength" : 0.50, "wind_frequency" : 0.75, "wind_speed" : 0.35}],
	["Violent", {"wind_strength" : 0.75, "wind_frequency" : 1.00, "wind_speed" : 0.50}]
]

func set_wind_intensity(value: float) -> void:
	_wind_intensity = value
	var preset = presets[int(value)]
	for material in _wind_materials:
		for setting in preset[1]:
			material.set_shader_param(setting, preset[1][setting])


func set_wind_angle(value: float) -> void:
	_wind_angle = value
	for material in _wind_materials:
		material.set_shader_param("wind_angle", value)


func _ready() -> void:
	_intensity_slider.connect("value_changed", self, "_on_intensity_value_changed")
	_angle_slider.connect("value_changed", self, "_on_angle_value_changed")


func _on_intensity_value_changed(value: float) -> void:
	var preset = presets[int(value)]
	_intensity_value_label.text = preset[0]
	set_wind_intensity(value)


func _on_angle_value_changed(value: float) -> void:
	_angle_value_label.text = str(value)
	set_wind_angle(value)
