extends Node2D

@export var asteroid: Texture2D
@export var spawn_radius := 960.0

@onready var rng := RandomNumberGenerator.new()


func _ready() -> void:
	rng.randomize()

	var spawn_direction := Vector2.UP.rotated(deg_to_rad(owner.direction_degrees))

	var trail_length: float = owner.trail_length

	var cells := trail_length / spawn_radius

	for c in cells:
		for direction_mod in [-1.0, 1.0]:
			var spawn_center: Vector2 = global_position + (spawn_direction * spawn_radius * c)
			spawn_center += spawn_direction.rotated(PI / 2 * direction_mod) * spawn_radius

			var cell_min := spawn_center - Vector2.ONE * spawn_radius / 2
			var cell_max := spawn_center + Vector2.ONE * spawn_radius / 2

			var cell_spawn := Vector2(
				rng.randf_range(cell_min.x, cell_max.x), rng.randf_range(cell_min.y, cell_max.y)
			)

			var spawned_asteroid := Sprite2D.new()
			spawned_asteroid.texture = asteroid
			add_child(spawned_asteroid)
			spawned_asteroid.global_position = cell_spawn
			spawned_asteroid.scale *= rng.randf_range(0.25, 0.75)
			spawned_asteroid.rotation = rng.randf_range(-PI, PI)
