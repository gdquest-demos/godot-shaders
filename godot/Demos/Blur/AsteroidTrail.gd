extends Node2D

export var asteroid: Texture
export var spawn_radius: float

onready var rng := RandomNumberGenerator.new()


func _ready() -> void:
	rng.randomize()

	var spawn_direction := Vector2.UP.rotated(deg2rad(owner.direction_degrees))

	var trail_length: float = owner.trail_length

	var cells := trail_length / spawn_radius

	for c in range(cells):
		for i in range(2):
			var direction_mod := -1.0 + 2 * i

			var spawn_center := global_position + (spawn_direction * spawn_radius * c)
			spawn_center += spawn_direction.rotated(PI / 2 * direction_mod) * spawn_radius

			var cell_min := spawn_center - Vector2.ONE * spawn_radius / 2
			var cell_max := spawn_center + Vector2.ONE * spawn_radius / 2

			var cell_spawn := Vector2(
				rng.randf_range(cell_min.x, cell_max.x), rng.randf_range(cell_min.y, cell_max.y)
			)

			var spawned_asteroid := Sprite.new()
			spawned_asteroid.texture = asteroid
			add_child(spawned_asteroid)
			spawned_asteroid.global_position = cell_spawn
			spawned_asteroid.scale *= rng.randf_range(0.25, 0.75)
			spawned_asteroid.rotation = rng.randf_range(-PI, PI)
