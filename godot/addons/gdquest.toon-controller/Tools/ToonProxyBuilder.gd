tool
class_name ToonProxyBuilder
extends Node

enum LightRole { KEY, FILL, KICK }

export (LightRole) var light_role := 0 setget _set_light_role
export var emits_shadows := false setget _set_emits_shadows
export var specular_material: ShaderMaterial setget _set_specular_material

var light_proxy: Node
var specular_proxy: Node

var light_remote: RemoteTransform
var specular_remote: RemoteTransform

var abort_deletion := false

onready var scene_root: Node = (
	get_tree().edited_scene_root
	if Engine.editor_hint
	else get_tree().root
)
onready var builder: ToonSceneBuilder = scene_root.find_node(
	"ToonSceneBuilder", true, false
)


func _ready():
	if not builder:
		return

	var parent := get_parent()
	
	light_proxy = builder.light_data.find_node(parent.name, true, false)
	specular_proxy = builder.specular_data.find_node(parent.name, true, false)

	if Engine.editor_hint:
		_build_missing_proxies(parent)

		parent.connect("renamed", self, "_on_parent_renamed")
		parent.connect("tree_exiting", self, "_on_parent_tree_exiting")
		scene_root.connect("tree_exiting", self, "_on_root_tree_exiting")

	_set_materials(light_proxy, ToonSceneBuilder.DataType.LIGHT)
	_set_materials(specular_proxy, ToonSceneBuilder.DataType.SPECULAR)


func _build_missing_proxies(parent: Node) -> void:
	var light_missing: bool = light_proxy == null
	var specular_missing: bool = specular_proxy == null
	
	yield(get_tree(), "idle_frame")

	if light_missing or specular_missing:
		parent.remove_child(self)

	if light_missing:
		var result := _build_remote_duplicates(
			parent, ToonSceneBuilder.DataType.LIGHT
		)

		light_proxy = result.proxy
		light_remote = result.proxy_remote
	else:
		light_remote = parent.find_node("LightRemote", true, false)

	if specular_missing:
		var result := _build_remote_duplicates(
			parent, ToonSceneBuilder.DataType.SPECULAR
		)

		specular_proxy = result.proxy
		specular_remote = result.proxy_remote
	else:
		specular_remote = parent.find_node("SpecularRemote", true, false)

	if light_missing or specular_missing:
		parent.add_child(self)
		owner = scene_root
		if parent is ToonCamera:
			parent.toggle_remotes()


func _build_remote_duplicates(parent: Node, type: int) -> Dictionary:
	var proxy: Node = parent.duplicate()
	var proxy_remote := RemoteTransform.new()

	parent.add_child(proxy_remote)
	proxy_remote.owner = scene_root

	match type:
		ToonSceneBuilder.DataType.LIGHT:
			builder.light_data.add_child(proxy)
			if proxy is Light:
				proxy.light_color = Color.red
			proxy_remote.name = "LightRemote"
		ToonSceneBuilder.DataType.SPECULAR:
			builder.specular_data.add_child(proxy)
			proxy_remote.name = "SpecularRemote"

	proxy.owner = scene_root

	proxy_remote.remote_path = "../%s" % parent.get_path_to(proxy)

	return {"proxy": proxy, "proxy_remote": proxy_remote}


func _set_materials(parent: Node, type: int) -> void:
	if not parent:
		return
	if parent is MeshInstance:
		var mat_count: int = parent.get_surface_material_count()
		
		for mat in range(mat_count):
			match type:
				ToonSceneBuilder.DataType.LIGHT:
					parent.set_surface_material(mat, builder.white_diffuse_material)
				ToonSceneBuilder.DataType.SPECULAR:
					parent.set_surface_material(mat, specular_material if specular_material else builder.specular_material)

	for child in parent.get_children():
		_set_materials(child, type)


func _set_light_role(value: int) -> void:
	light_role = value

	if not Engine.editor_hint:
		return
	if not is_inside_tree():
		yield(self, "ready")

	if light_proxy is Light:
		match light_role:
			LightRole.KEY:
				light_proxy.light_color = Color.red
			LightRole.FILL:
				light_proxy.light_color = Color.green
			LightRole.KICK:
				light_proxy.light_color = Color.blue

	if specular_proxy is Light:
		match light_role:
			LightRole.KEY:
				specular_proxy.light_energy = 1
				specular_proxy.show()
			LightRole.FILL:
				specular_proxy.light_energy = 0
				specular_proxy.hide()
			LightRole.KICK:
				specular_proxy.light_energy = 0
				specular_proxy.hide()


func _set_emits_shadows(value: bool) -> void:
	emits_shadows = value

	if not Engine.editor_hint:
		return
	if not is_inside_tree():
		yield(self, "ready")

	if light_proxy is Light:
		light_proxy.shadow_enabled = emits_shadows
		specular_proxy.shadow_enabled = emits_shadows


func _set_specular_material(value: ShaderMaterial) -> void:
	specular_material = value
	if not is_inside_tree():
		yield(self, "ready")
	
	_set_materials(specular_proxy, ToonSceneBuilder.DataType.SPECULAR)


func _on_parent_renamed() -> void:
	if light_proxy:
		light_proxy.name = get_parent().name
		light_remote.remote_path = (
			"../%s"
			% get_parent().get_path_to(light_proxy)
		)

	if specular_proxy:
		specular_proxy.name = get_parent().name
		specular_remote.remote_path = (
			"../%s"
			% get_parent().get_path_to(specular_proxy)
		)


func _on_parent_tree_exiting() -> void:
	abort_deletion = false
	Engine.get_main_loop().connect("idle_frame", self, "_on_SceneTree_idle_frame", [], CONNECT_ONESHOT)


func _on_SceneTree_idle_frame() -> void:
	if abort_deletion:
		return

	if light_proxy:
		light_proxy.queue_free()

	if specular_proxy:
		specular_proxy.queue_free()


func _on_root_tree_exiting() -> void:
	abort_deletion = true
