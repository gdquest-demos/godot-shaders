tool
extends Particles2D

export var emission_mask: Texture
export var is_force_stopped := false setget force_stop


func _physics_process(_delta: float) -> void:
	if not is_force_stopped:
		_process_texture()


func _process_texture() -> void:
	var data := emission_mask.get_data().data
	var width: int = data.width
	var height: int = data.height
	var raw: PoolByteArray = data.data

	var positions := PoolVector2Array()

	for x in range(width):
		for y in range(height):
			var idx := (y * width + x) * 4
			var byte: int = raw[idx]
			if byte > 128:
				positions.append(Vector2(x, y) * 8 - position)

	if positions.size() == 0:
		emitting = false
	else:
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

		process_material.emission_shape = ParticlesMaterial.EMISSION_SHAPE_POINTS
		process_material.emission_point_texture = image_texture
		process_material.emission_point_count = positions.size()

		emitting = true


func force_stop(value: bool) -> void:
	is_force_stopped = value
	if is_force_stopped:
		emitting = false
