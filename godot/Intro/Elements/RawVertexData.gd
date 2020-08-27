extends Node2D

export var Vertex: PackedScene
export var theme: Theme
export var v_code: PackedScene

var data := [
	"-1   1   1",
	" 1   1  -1",
	" 1   1   1",
	"-1   1  -1",
	"-1  -1   1",
	" 1  -1  -1",
	" 1  -1   1",
	"-1  -1  -1",
	" 1   1   1",
	"-1   1  -1",
	" 1   1  -1",
	"-1   1   1",
	" 1  -1   1",
	"-1  -1  -1",
	" 1  -1  -1",
	"-1  -1   1",
	" 1   1   1",
	"-1  -1   1",
	"-1   1   1",
	" 1  -1   1",
	" 1   1  -1",
	"-1  -1  -1",
	"-1   1  -1",
	" 1  -1  -1"
]

var labels := []
var vertices := []
var vertex_start_positions := []
var vertex_end_positions := []
var culled_indices := []
var indices := []

onready var tween := $Tween


func setup(cube: MeshInstance, camera: Camera) -> void:
	var x := 50.0
	var y := 60.0

	_extract_end_positions(cube, camera)

	for i in range(24):
		var vertex := Vertex.instance()
		add_child(vertex)

		vertex.position = Vector2(x, y)
		vertices.append(vertex)
		vertex_start_positions.append(vertex.position)

		var label := Label.new()
		label.text = data[i]
		add_child(label)

		label.rect_position = Vector2(x + 30, y - 18)
		label.theme = theme
		label.modulate = Color.white
		labels.append(label)

		y += 27


func animate() -> void:
	yield(animate_vertices(), "completed")
	remove_labels()


func remove_labels() -> void:
	for l in labels:
		tween.interpolate_property(l, "modulate", Color.white, Color.transparent, 1)
	tween.start()
	yield(tween, "tween_all_completed")
	for l in labels:
		l.queue_free()


func animate_vertices() -> void:
	var anim_time := 0.5
	for i in range(0, indices.size(), 3):
		var i1: int = indices[i]
		var i2: int = indices[i + 1]
		var i3: int = indices[i + 2]

		tween.interpolate_property(
			vertices[i1],
			"position",
			vertices[i1].position,
			vertex_end_positions[i1],
			anim_time,
			Tween.TRANS_SINE,
			2
		)
		tween.interpolate_property(
			vertices[i2],
			"position",
			vertices[i2].position,
			vertex_end_positions[i2],
			anim_time,
			Tween.TRANS_SINE,
			2
		)
		tween.interpolate_property(
			vertices[i3],
			"position",
			vertices[i3].position,
			vertex_end_positions[i3],
			anim_time,
			Tween.TRANS_SINE,
			2
		)
		tween.start()
		yield(tween, "tween_all_completed")
		yield(get_tree().create_timer(anim_time), "timeout")
		if i == 6:
			anim_time = 0.3
		if i == 21:
			anim_time = 0.15


func do_cull() -> void:
	for i in range(culled_indices.size()):
		tween.interpolate_property(
			vertices[culled_indices[i]], "modulate", Color.white, Color.red, 1
		)
	tween.start()
	yield(tween, "tween_all_completed")
	for i in range(culled_indices.size()):
		tween.interpolate_property(
			vertices[culled_indices[i]], "modulate", Color.red, Color.transparent, 1
		)
	tween.start()
	yield(tween, "tween_all_completed")


func _extract_end_positions(mesh_instance: MeshInstance, camera: Camera) -> void:
	var mesh := mesh_instance.mesh

	var pixel_data: Array = mesh.surface_get_arrays(0)
	var mesh_vertices: Array = pixel_data[ArrayMesh.ARRAY_VERTEX]
	var normals: Array = pixel_data[ArrayMesh.ARRAY_NORMAL]
	var _indices: Array = pixel_data[ArrayMesh.ARRAY_INDEX]
	indices = _indices
	var camera_normal := -camera.global_transform.basis.z
	vertex_end_positions.resize(mesh_vertices.size())

	var xform := mesh_instance.global_transform

	for i in range(_indices.size()):
		var v: Vector3 = mesh_vertices[_indices[i]]

		var vertex: Vector3 = xform.xform(v)
		var normal: Vector3 = xform.basis.xform(normals[_indices[i]])

		if normal.dot(camera_normal) > 0:
			culled_indices.append(_indices[i])

		var end_point := camera.unproject_position(vertex)  # / 0.078

		vertex_end_positions[_indices[i]] = end_point
