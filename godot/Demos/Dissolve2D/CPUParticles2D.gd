tool
extends CPUParticles2D

export var emission_mask: Texture
export var is_force_stopped := false setget force_stop


func _physics_process(_delta: float) -> void:
	if not is_force_stopped:
		_process_texture(emission_mask)


func _process_texture(texture: Texture) -> void:
	var data := texture.get_data()
	data.convert(Image.FORMAT_R8)
	var w := data.get_width()
	var h := data.get_height()
	var raw: PoolByteArray = data.data.data

	var positions := PoolVector2Array()

	for x in range(w):
		for y in range(h):
			var idx := y * w + x
			var byte: int = raw[idx]
			if byte > 76:
				positions.append(Vector2(x, y) * 20)

	if positions.size() > 0:
		emitting = true
	else:
		emitting = false
	emission_points = positions


func force_stop(value: bool) -> void:
	is_force_stopped = value
	if is_force_stopped:
		emitting = false
