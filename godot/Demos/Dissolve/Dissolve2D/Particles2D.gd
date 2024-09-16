@tool
extends GPUParticles2D

@export var emission_mask: Texture2D

func _physics_process(_delta: float) -> void:
	var data := emission_mask.get_data().data
	var width: int = data.width
	var height: int = data.height
	var raw: PackedByteArray = data.data

	var positions := PackedVector2Array()

	for x in width:
		for y in height:
			var idx: int = (y * width + x) * 4
			var byte: int = raw[idx]
			if byte > 128:
				positions.append(Vector2(x, y) * 8 - position)
				
	emitting = not positions.is_empty()
	
	if emitting:
		var buffer := StreamPeerBuffer.new()

		for pos in positions:
			buffer.put_float(pos.x)
			buffer.put_float(pos.y)

		var new_width := 2048
		var new_height := (positions.size() / 2048) + 1

		var output := buffer.data_array
		output.resize(new_width * new_height * 8)

		var image := Image.new()
		image.create_from_data(new_width, new_height, false, Image.FORMAT_RGF, output)

		var image_texture := ImageTexture.new()
		image_texture.create_from_image(image)

		process_material.emission_shape = ParticleProcessMaterial.EMISSION_SHAPE_POINTS
		process_material.emission_point_texture = image_texture
		process_material.emission_point_count = positions.size()


func force_stop(is_force_stopped: bool) -> void:
	set_physics_process(not is_force_stopped)
	if is_force_stopped:
		emitting = false
