extends Viewport

export var step_distance := 0.1
export var interactive_actor_path: NodePath
export var interactive_actor_footprint: NodePath
export var interactive_snow_size: Vector2 = Vector2(16, 16)

var _prev_player_pos = Vector2()

onready var _line: Line2D = $Line2D
onready var _player = get_node(interactive_actor_path)
onready var _footprint = get_node(interactive_actor_footprint)

func _ready() -> void:
	get_texture().set_flags(Texture.FLAG_FILTER)
	_prev_player_pos = Vector2(_player.global_transform.origin.x, _player.global_transform.origin.z)
	var player_pos = _prev_player_pos
	player_pos += interactive_snow_size / 2.0
	_footprint.position = (player_pos / interactive_snow_size) * size
	_line.add_point(_footprint.position)


func _process(_delta: float) -> void:
	var player_pos = Vector2(_player.global_transform.origin.x, _player.global_transform.origin.z)
	if player_pos.distance_to(_prev_player_pos) < step_distance:
		return
	_prev_player_pos = player_pos
	player_pos += interactive_snow_size / 2.0
	_footprint.position = (player_pos / interactive_snow_size) * size
	_line.add_point(_footprint.position)
	if _line.get_point_count() > 1024:
		var old_line = _line.duplicate()
		add_child(old_line)
		_line.clear_points()
		_line.add_point(_footprint.position)
