tool
extends MultiMeshInstance

export(Vector2) var extents := Vector2.ONE
export(bool) var spawn_outside_circle := false
export(float) var radius := 12.0

func _ready() -> void:
	var rng := RandomNumberGenerator.new()
	rng.randomize()
	
	var theta := 0
	var increase := 1
	var center := get_parent().global_transform.origin
	
	for i in multimesh.instance_count:
		var transform := Transform().rotated(Vector3.UP, rng.randf_range(-PI/2, PI/2))
		var x:float
		var z:float
		if (!spawn_outside_circle):
			x := rng.randf_range(-extents.x, extents.x)
			z := rng.randf_range(-extents.y, extents.y)
		else:
			x := center.x + (radius + rng.randf_range(0,extents.x) ) * cos(theta)
			z := center.z + (radius + rng.randf_range(0,extents.y) ) * sin(theta)
			theta += increase
		transform.origin := Vector3(x, 0, z)

		multimesh.set_instance_transform(i, transform)
		multimesh.set_instance_custom_data(i, Color(rng.randf(), 0, rng.randf(), 0))
		
