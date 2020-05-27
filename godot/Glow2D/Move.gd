extends Sprite

export var speed := 100.0
export var horizontal := false

onready var direction := Vector2.RIGHT if horizontal else Vector2.UP

onready var start_position := position


func _process(delta):
	position += direction * speed * delta

	if position.distance_to(start_position) > 100:
		direction *= -1
