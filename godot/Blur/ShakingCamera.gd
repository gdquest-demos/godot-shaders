tool
extends Camera2D
# Shakes the screen when is_shaking is set to true
# To make it react to events happening in the game world, use the Events signal routing singleton
# Uses different smoothing values depending on the active controller

onready var timer = $Timer

export var amplitude = 4.0
export var duration = 0.3 setget set_duration
export var DAMP_EASING = 1.0
export var is_shaking = false setget set_is_shaking

enum States {IDLE, SHAKING}
var state = States.IDLE


func _ready() -> void:
# warning-ignore:return_value_discarded
	timer.connect('timeout', self, '_on_ShakeTimer_timeout')

	self.duration = duration
	set_process(false)


func _process(_delta) -> void:
	var damping = ease(timer.time_left / timer.wait_time, DAMP_EASING)
	offset = Vector2(
		rand_range(amplitude, -amplitude) * damping,
		rand_range(amplitude, -amplitude) * damping)


func _get_configuration_warning() -> String:
	return "" if $Timer else "%s requires a Timer child named Timer" % name


func set_duration(value: float) -> void:
	duration = value
	if timer:
		timer.wait_time = duration


func set_is_shaking(value: bool) -> void:
	is_shaking = value
	if is_shaking:
		_change_state(States.SHAKING)
	else:
		_change_state(States.IDLE)


func _change_state(new_state: int) -> void:
	match new_state:
		States.IDLE:
			offset = Vector2()
			set_process(false)
		States.SHAKING:
			set_process(true)
			timer.start()
	state = new_state


func _on_ShakeTimer_timeout() -> void:
	self.is_shaking = false
