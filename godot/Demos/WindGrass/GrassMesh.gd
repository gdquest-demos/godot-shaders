tool
extends MultiMeshInstance

export var extents := Vector2.ONE


func _ready() -> void:
	var rng := RandomNumberGenerator.new()
	rng.randomize()
	for i in multimesh.instance_count:
		var transform := Transform().rotated(Vector3.UP, rng.randf_range(-PI/2, PI/2))
		
		var x := rng.randf_range(-extents.x, extents.x)
		var z := rng.randf_range(-extents.y, extents.y)
		transform.origin = Vector3(x, 0, z)

		multimesh.set_instance_transform(i, transform)
		multimesh.set_instance_custom_data(i, Color(rng.randf(), 0, rng.randf(), 0))
