# Class that automatically converts mesh surfaces into ArrayMesh and adds
# 100% smoothed normals into the vertex color channel in the 0..1 range.
# 
# Those smoothed normals can be brought back into -1..1 range by subtracting
# vec3(0.5) and multiplying the difference by 2.0. For example:
# 
# ```glsl
# 	vec3 normal = (COLOR.xyz-vec3(0.5))*2.0;
# 	VERTEX += (normal * thickness);
# ```
class_name SmoothNormalsMeshInstance
extends MeshInstance

# When true, smaller triangles will not provide as much influence as larger ones
export var use_area_weighed_normals := true

# When true, will go counter-clockwise instead of clockwise, which will reverse
# the normals' direction.
export var use_reverse_winding := false


func _ready() -> void:
	var surface_count := mesh.get_surface_count()
	var new_mesh := ArrayMesh.new()
	var materials := []
	
	for i in range(surface_count):
		var data := mesh.surface_get_arrays(i)
		var vertices: Array = data[ArrayMesh.ARRAY_VERTEX]
		var indices: Array = data[ArrayMesh.ARRAY_INDEX]
		
		if indices:
			data[ArrayMesh.ARRAY_COLOR] = _generate_smooth_normals_as_color(vertices, indices)
		else:
			data[ArrayMesh.ARRAY_COLOR] = _generate_smooth_normals_as_color(vertices)
		
		new_mesh.add_surface_from_arrays(Mesh.PRIMITIVE_TRIANGLES, data)
		materials.append(get_surface_material(i))
	
	mesh = new_mesh
	for i in materials.size():
		set_surface_material(i, materials[i])


func _generate_smooth_normals_as_color(vertices: Array, indices := []) -> PoolColorArray:
	var face_normals := {}
	
	if indices.size() > 0:
		for i in range(0, indices.size(), 3):
			var i1: int = indices[i]
			var i2: int = indices[i+1]
			var i3: int = indices[i+2]
			
			_accumulate_face_normals([vertices[i1], vertices[i2], vertices[i3]], face_normals)
	else:
		for v in range(0, vertices.size(), 3):
			_accumulate_face_normals([vertices[v], vertices[v+1], vertices[v+2]], face_normals)
	
	return _get_smoothed_as_color_channel(vertices, face_normals)


func _accumulate_face_normals(triangle: Array, face_normals: Dictionary) -> void:
	var v1: Vector3 = triangle[0]
	var v2: Vector3 = triangle[1]
	var v3: Vector3 = triangle[2]
	
	var normal: Vector3
	var a1: float
	var a2: float
	var a3: float
	
	if use_reverse_winding:
		normal = (v2-v1).cross(v3-v1)
	else:
		normal = (v3-v1).cross(v2-v1)
	
	if not use_area_weighed_normals:
		normal = normal.normalized()
	
	if use_reverse_winding:
		a1 = (v2-v1).angle_to(v3-v1)
		a2 = (v3-v2).angle_to(v1-v2)
		a3 = (v1-v3).angle_to(v2-v3)
	else:
		a1 = (v3-v1).angle_to(v2-v1)
		a2 = (v1-v2).angle_to(v3-v2)
		a3 = (v2-v3).angle_to(v1-v3)
	
	if not face_normals.has(v1):
		face_normals[v1] = Vector3.ZERO
	if not face_normals.has(v2):
		face_normals[v2] = Vector3.ZERO
	if not face_normals.has(v3):
		face_normals[v3] = Vector3.ZERO
	
	face_normals[v1] += (normal * a1)
	face_normals[v2] += (normal * a2)
	face_normals[v3] += (normal * a3)


func _get_smoothed_as_color_channel(vertices: Array, faces: Dictionary) -> PoolColorArray:
	var output := PoolColorArray()
	for v in vertices:
		var normal: Vector3 = (faces[v].normalized() / 2.0) + Vector3(0.5, 0.5, 0.5)
		output.append(Color(normal.x, normal.y, normal.z))
	return output
