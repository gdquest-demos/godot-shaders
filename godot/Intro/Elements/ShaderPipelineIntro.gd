extends Control

@onready var _cube_scene: Node3D = $SubViewport/Node3D
@onready var _raw_vertices: Node2D = $RawVertexData
@onready var _title: Label = $Title
@onready var _line_drawers: Node2D = $LineDrawers
@onready var _pixels: Node2D = $Pixels
@onready var _animation_player: AnimationPlayer = $AnimationPlayer
@onready var _main_cube: MeshInstance3D = $SubViewport/Node3D/MainCube
@onready var _camera: Camera3D = $SubViewport/Node3D/Camera3D

func _ready() -> void:
	_pixels.modulate = Color.TRANSPARENT
	_cube_scene.setup()
	_raw_vertices.setup(_main_cube, _camera)
	_line_drawers.setup(
		_raw_vertices.vertex_end_positions,
		_cube_scene.get_node("MainCube").mesh.surface_get_arrays(0)[ArrayMesh.ARRAY_INDEX],
		_raw_vertices.culled_indices
	)
