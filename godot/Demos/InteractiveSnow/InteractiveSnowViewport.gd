extends Viewport

export var interactive_actor_path: NodePath
export var interactive_actor_footprint: NodePath
export var line2d: NodePath = "Line2D"
export var interactive_snow_size: Vector2 = Vector2(32,32)

var _prev_player_pos = Vector2()

func _ready():
	get_texture().set_flags(Texture.FLAG_FILTER)
	var player = get_node(interactive_actor_path)
	_prev_player_pos = Vector2(player.global_transform.origin.x, player.global_transform.origin.z)
	var player_pos = _prev_player_pos
	player_pos += interactive_snow_size/2.0;
	get_node(interactive_actor_footprint).global_position = (player_pos/ interactive_snow_size) * size
	var line = get_node("Line2D")
	line.add_point( (player_pos/ interactive_snow_size) * size)

func _process(delta):
	var player = get_node(interactive_actor_path)
	var player_pos = Vector2(player.global_transform.origin.x, player.global_transform.origin.z)
	if player_pos.distance_to(_prev_player_pos) < 0.1:
		return
	_prev_player_pos = player_pos
	player_pos += interactive_snow_size/2.0;
	get_node(interactive_actor_footprint).global_position = (player_pos/ interactive_snow_size) * size
	var line = get_node("Line2D")
	line.add_point( (player_pos/ interactive_snow_size) * size)
	if line.get_point_count() > 1024:
		var old_line = line.duplicate()
		add_child(old_line)
		line.clear_points()
		line.add_point((player_pos/ interactive_snow_size) * size)
