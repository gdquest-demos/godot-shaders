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

	var st := SurfaceTool.new()

	for i in range(surface_count):
		st.begin(Mesh.PRIMITIVE_TRIANGLES)
		st.create_from(mesh, i)
		st.deindex()

		var data := st.commit_to_arrays()

		st.begin(Mesh.PRIMITIVE_TRIANGLES)

		st.add_smooth_group(true)

		for v in data[ArrayMesh.ARRAY_VERTEX]:
			st.add_vertex(v)

		st.generate_normals()

		data[ArrayMesh.ARRAY_COLOR] = _convert_normals_to_color(st.commit_to_arrays())

		new_mesh.add_surface_from_arrays(Mesh.PRIMITIVE_TRIANGLES, data)
		materials.append(get_surface_material(i))

	mesh = new_mesh
	for i in materials.size():
		set_surface_material(i, materials[i])


func _convert_normals_to_color(data: Array) -> PoolColorArray:
	var normals: PoolVector3Array = data[ArrayMesh.ARRAY_NORMAL]

	var out_color := PoolColorArray()
	for normal in normals:
		out_color.append(
			Color(normal.x * 0.5 + 0.5, normal.y * 0.5 + 0.5, normal.z * 0.5 + 0.5, 1.0)
		)

	return out_color
