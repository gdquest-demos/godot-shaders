@tool
class_name ToonSceneBuilder
extends Node

enum DataType { LIGHT, SPECULAR }

const VIEW_NAMES := ["ToonLightDataView", "ToonSpecularDataView"]

@export var shadow_resolution: int = 2048: set = _set_shadow_resolution
@export var specular_material: StandardMaterial3D
@export var white_diffuse_material: StandardMaterial3D
@export var specular_ignores_shadows := false: set = _set_specular_ignores_shadows

var light_data: SubViewport
var specular_data: SubViewport

@onready var scene_root := get_tree().edited_scene_root if Engine.is_editor_hint() else get_tree().root


func _ready() -> void:
	if not specular_material:
		specular_material = StandardMaterial3D.new()
		specular_material.albedo_color = Color.BLACK
		specular_material.roughness = 0.4
		specular_material.flags_disable_ambient_light = true

	if not white_diffuse_material:
		white_diffuse_material = StandardMaterial3D.new()
		white_diffuse_material.flags_disable_ambient_light = true

	light_data = _find_viewport(DataType.LIGHT)
	specular_data = _find_viewport(DataType.SPECULAR)

	if Engine.is_editor_hint():
		if not get_index() == 0:
			scene_root.call_deferred("move_child", self, 0)

		if not light_data:
			light_data = await _build_data(DataType.LIGHT)

		if not specular_data:
			specular_data = await _build_data(DataType.SPECULAR)


func get_class() -> String:
	return "ToonSceneBuilder"


func _find_viewport(type: int) -> SubViewport:
	var viewport_name: String = VIEW_NAMES[type]

	var container: ToonViewportContainer = scene_root.find_child(viewport_name, true, false)

	if container:
		return container.get_child(0) as SubViewport
	else:
		return null


func _build_data(type: int) -> SubViewport:
	var view := ToonViewportContainer.new()
	view.name = VIEW_NAMES[type]
	view.stretch = true
	view.anchor_right = 1
	view.anchor_bottom = 1
	view.self_modulate.a = 0

	var viewport := SubViewport.new()
	viewport.transparent_bg = true
	viewport.world_3d = World3D.new()
	#viewport.usage = Viewport.USAGE_3D_NO_EFFECTS
	viewport.render_target_update_mode = SubViewport.UPDATE_ALWAYS
	viewport.msaa = ProjectSettings.get_setting("rendering/quality/filters/msaa")
	viewport.shadow_atlas_size = shadow_resolution
	await get_tree().idle_frame
	view.add_child(viewport)

	scene_root.add_child(view)
	scene_root.call_deferred("move_child", view, type + 1)
	view.owner = scene_root
	viewport.owner = scene_root

	return viewport


func _set_shadow_resolution(value: int) -> void:
	shadow_resolution = value

	if not is_inside_tree():
		await self.ready

	if light_data:
		light_data.shadow_atlas_size = shadow_resolution
	if specular_data:
		specular_data.shadow_atlas_size = (0 if specular_ignores_shadows else shadow_resolution)


func _set_specular_ignores_shadows(value: bool) -> void:
	specular_ignores_shadows = value

	if not is_inside_tree():
		await self.ready

	self.shadow_resolution = shadow_resolution
