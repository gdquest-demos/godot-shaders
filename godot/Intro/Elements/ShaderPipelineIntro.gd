extends Control

onready var cube_scene := $Viewport/Spatial
onready var raw_vertices := $RawVertexData
onready var tween := $Tween
onready var title := $Title
onready var line_drawers := $LineDrawers
onready var timer := $Timer
onready var full_res := $FullRes
onready var pixels := $Pixels
onready var scaled_res := $Scaled


func _ready() -> void:
	pixels.modulate = Color.transparent
	cube_scene.setup()
	raw_vertices.setup($Viewport/Spatial/MainCube, $Viewport/Spatial/Camera)
	line_drawers.setup(
		raw_vertices.vertex_end_positions,
		cube_scene.get_node("MainCube").mesh.surface_get_arrays(0)[ArrayMesh.ARRAY_INDEX],
		raw_vertices.culled_indices
	)

	title.text = "Raw Vertex Data"


func _unhandled_input(event: InputEvent) -> void:
	if event.is_action_pressed("ui_accept"):
		animate()


func animate() -> void:
	timer.start(2)
	yield(timer, "timeout")

	title.change_title("Vertex shader and shape recognition")
	raw_vertices.animate()
	yield(line_drawers.do_draw(), "completed")

	timer.start(2)
	yield(timer, "timeout")

	title.change_title("Culling")
	line_drawers.do_cull()
	yield(raw_vertices.do_cull(), "completed")

	tween.interpolate_property(raw_vertices, "modulate", Color.white, Color.transparent, 1)
	tween.start()

	timer.start(2)
	yield(timer, "timeout")

	title.change_title("Rasterization")
	tween.interpolate_property(line_drawers, "modulate", Color.white, Color.transparent, 1)
	tween.interpolate_property(pixels, "modulate", Color.transparent, Color.white, 1)
	tween.start()
	yield(cube_scene.show_main_cube(), "completed")

	timer.start(2)
	yield(timer, "timeout")

	title.change_title("Fragment Shader")

	yield(pixels.do_render(), "completed")

	timer.start(2)
	yield(timer, "timeout")

	title.change_title("Clipping")
	yield(cube_scene.show_clipped_cube(), "completed")

	timer.start(2)
	yield(timer, "timeout")

	title.change_title("Blending")
	yield(cube_scene.show_blended_cube(), "completed")

	timer.start(2)
	yield(timer, "timeout")

	title.change_title("Done")

	tween.interpolate_property(full_res, "modulate", Color.transparent, Color.white, 1)
	tween.start()
