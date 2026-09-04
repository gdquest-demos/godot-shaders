extends Area3D

var animated_outline: AnimatedOutline


func _ready() -> void:
	animated_outline = AnimatedOutline.new(
		self, get_parent().get_surface_override_material(0).next_pass, 0.5, 0.15
	)


func pop_in() -> void:
	animated_outline.pop_in()


func pop_out() -> void:
	animated_outline.pop_out()
