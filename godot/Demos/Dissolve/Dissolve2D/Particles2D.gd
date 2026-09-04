@tool
extends GPUParticles2D

@export var emission_mask: Texture2D

func _physics_process(_delta: float) -> void:
	if emission_mask == null:
		return

	# Texture.get_data() became Texture2D.get_image() in Godot 4. Reading pixels
	# through get_pixel() keeps this independent of the imported texture format.
	var image := emission_mask.get_image()
	if image.is_compressed():
		image.decompress()

	var positions := PackedVector2Array()

	for x in image.get_width():
		for y in image.get_height():
			if image.get_pixel(x, y).r > 0.5:
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

		# Image and ImageTexture are built through static factory methods now.
		var points_image := Image.create_from_data(new_width, new_height, false, Image.FORMAT_RGF, output)
		var image_texture := ImageTexture.create_from_image(points_image)

		process_material.emission_shape = ParticleProcessMaterial.EMISSION_SHAPE_POINTS
		process_material.emission_point_texture = image_texture
		process_material.emission_point_count = positions.size()


func force_stop(is_force_stopped: bool) -> void:
	set_physics_process(not is_force_stopped)
	if is_force_stopped:
		emitting = false
