extends Sprite

export var travel_speed := 2500.0
export var blur_provider_path := NodePath()
export var shaking_camera_background_path := NodePath()

var desired_speed := 0.0
var accel := 2500.0
var speed := 0.0

onready var blur_provider := get_node(blur_provider_path)
onready var trail_direction := Vector2.UP
onready var shaking_camera_background := get_node(shaking_camera_background_path)
onready var _animation_player: AnimationPlayer = $AnimationPlayer
onready var _camera_background_transform: RemoteTransform2D = $CameraBackgroundTransform


func _ready() -> void:
	if blur_provider:
		trail_direction = trail_direction.rotated(deg2rad(blur_provider.direction_degrees))
		rotation = deg2rad(blur_provider.direction_degrees)
	_animation_player.play("Boost")
	yield(_animation_player, "animation_finished")
	desired_speed = travel_speed
	if shaking_camera_background:
		shaking_camera_background.is_shaking = true
	speed = 1000.0


func _process(delta: float) -> void:
	if speed < desired_speed:
		speed = min(speed + accel * delta, desired_speed)
		if blur_provider:
			blur_provider.emit_signal("speeding_up", speed / desired_speed)
	if speed == travel_speed:
		_camera_background_transform.remote_path = ""

	position += trail_direction * speed * delta
