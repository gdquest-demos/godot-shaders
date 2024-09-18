extends SubViewport

#region vars
@export var interactive_actor_path := NodePath("../InteractiveSnowball")
@export var snow_plane_path := NodePath("../SnowPlane")

@onready var snow_size: Vector2 = get_node(snow_plane_path).mesh.size / 2
@onready var _player: MeshInstance3D = get_node(interactive_actor_path)
@onready var _footprint: Sprite2D = $Sprite2D
#endregion vars

#region Callbacks
func _ready() -> void:
	_footprint.position = get_world_to_viewport_position_verbose(_player.global_transform.origin)
	_player.snow_size = snow_size


func _process(_delta: float) -> void:
	# Calculate the new footprint position
	var player_pos = get_world_to_viewport_position_verbose(_player.global_transform.origin)
	# Compare the new footprint position to the old one, and make the transparency of the footprint
	# proportional. This makes standing still not distrub the snow.
	_footprint.modulate.a = _footprint.position.distance_to(player_pos)
	# Update the footprints position.
	_footprint.position = player_pos
#endregion Callbacks

#region 3d-to-2d
func get_world_to_viewport_position(world_position: Vector3) -> Vector2:
	# Convert from (-8, 8) 3D space to (0, 128) 2D space. y = (x + 8) * 8
	return (Vector2(world_position.x, world_position.z) + snow_size) * snow_size

func get_world_to_viewport_position_verbose(world_position: Vector3) -> Vector2:
	# Convert from (-8, 8) 3D space to (0, 128) 2D space.
	var x_component = remap(world_position.x, -snow_size.x, snow_size.x, 0, size.x)
	var y_component = remap(world_position.z, -snow_size.y, snow_size.y, 0, size.y)
	return (Vector2(x_component, y_component))
#endregion 3d-to-2d
