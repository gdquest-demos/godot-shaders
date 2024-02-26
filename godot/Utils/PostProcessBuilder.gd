class_name PostProcessBuilder
extends Control

@export (Array, Resource) var processing_steps := []
@export var scene: PackedScene


func _ready() -> void:
	var presentation := SubViewportContainer.new()
	presentation.anchor_right = 1
	presentation.anchor_bottom = 1
	presentation.stretch = true

	var top_parent: Node = presentation
	add_child(top_parent)

	for i in range(processing_steps.size() - 1, -1, -1):
		var step: PostProcessStep = processing_steps[i]
		if not step is PostProcessStep:
			continue

		var container := SubViewportContainer.new()
		container.stretch = true
		container.anchor_right = 1
		container.anchor_bottom = 1

		var viewport := SubViewport.new()
		viewport.render_target_update_mode = SubViewport.UPDATE_ALWAYS
		container.add_child(viewport)

		var mat := step.post_proces_shader.duplicate()
		container.material = mat

		top_parent.add_child(container)
		top_parent = viewport

	var instanced_scene := scene.instantiate()
	top_parent.add_child(instanced_scene)
