extends Viewport

export var interactive_actor_path: NodePath()
export var snow_size := Vector2(8, 8)

onready var _player = get_node(interactive_actor_path)
onready var _footprint: Sprite = $Sprite


func _ready() -> void:
	get_texture().set_flags(Texture.FLAG_FILTER)
	_footprint.position = get_world_to_viewport_position(_player.global_transform.origin)


func _process(_delta: float) -> void:
	var player_pos = get_world_to_viewport_position(_player.global_transform.origin)
	_footprint.modulate.a = _footprint.position.distance_to(player_pos)
	_footprint.position = player_pos


func get_world_to_viewport_position(world_position: Vector3) -> Vector2:
	# Convert from (-8, 8) 3D space to (0, 128) 2D space. y = (x + 8) * 8
	return (Vector2(world_position.x, world_position.z) + snow_size) * snow_size
