extends Node2D


func load_demo(scene_path: String) -> void:
	if not scene_path:
		return

	var demo := load(scene_path)
	if demo:
		add_child(demo.instance())


func unload() -> void:
	for node in get_children():
		call_deferred("remove_child", node)
		node.queue_free()


func is_loaded() -> bool:
	return get_child_count() > 0
