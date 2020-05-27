extends Sprite

export var prepass_viewport_path := NodePath()
export var glow_color := Color.white

var prepass_shader: Shader = preload("../shaders/glow_prepass.shader")

onready var prepass_viewport: Viewport = get_node(prepass_viewport_path)
onready var remote_transform := $RemoteTransform2D


func _ready() -> void:
	var sprite := Sprite.new()
	sprite.texture = texture
	sprite.position = position
	sprite.scale = scale
	sprite.material = ShaderMaterial.new()
	sprite.material.shader = prepass_shader
	sprite.material.set_shader_param("glow_color", glow_color)
	prepass_viewport.add_child(sprite)
	#remote_transform.remote_path = sprite.get_path()
