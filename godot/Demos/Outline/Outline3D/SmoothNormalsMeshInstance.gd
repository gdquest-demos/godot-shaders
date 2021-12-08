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

	var surface_tool := SurfaceTool.new()

	for surface_index in surface_count:
		surface_tool.begin(Mesh.PRIMITIVE_TRIANGLES)
		surface_tool.create_from(mesh, surface_index)
		surface_tool.deindex()

		var data := surface_tool.commit_to_arrays()

		surface_tool.begin(Mesh.PRIMITIVE_TRIANGLES)

		surface_tool.add_smooth_group(true)

		for vertex in data[ArrayMesh.ARRAY_VERTEX]:
			surface_tool.add_vertex(vertex)

		surface_tool.generate_normals()

		data[ArrayMesh.ARRAY_COLOR] = _convert_normals_to_color(surface_tool.commit_to_arrays())

		new_mesh.add_surface_from_arrays(Mesh.PRIMITIVE_TRIANGLES, data)
		materials.append(get_surface_material(surface_index))

	mesh = new_mesh
	for material_index in materials.size():
		set_surface_material(material_index, materials[material_index])


func _convert_normals_to_color(data: Array) -> PoolColorArray:
	var normals: PoolVector3Array = data[ArrayMesh.ARRAY_NORMAL]

	var out_color := PoolColorArray()
	for normal in normals:
		out_color.append(
			Color(normal.x * 0.5 + 0.5, normal.y * 0.5 + 0.5, normal.z * 0.5 + 0.5, 1.0)
		)

	return out_color
