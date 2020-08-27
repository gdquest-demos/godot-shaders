extends MeshInstance

onready var tween := $Tween


func _on_RigidBody_body_entered(body: Node) -> void:
	visible = true
	tween.interpolate_property(
		self, "scale", scale, Vector3(1.5, 1.5, 1.5), 0.5, Tween.TRANS_ELASTIC
	)
	tween.start()
