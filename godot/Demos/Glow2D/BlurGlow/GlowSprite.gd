extends Sprite2D

@export var prepass_viewport_path := NodePath()
@export var glow_color := Color.WHITE

var prepass_shader: Shader = preload("../shaders/glow_prepass.gdshader")

@onready var prepass_viewport: SubViewport = get_node(prepass_viewport_path)
@onready var remote_transform := $RemoteTransform2D


func _ready() -> void:
	var sprite := Sprite2D.new()
	sprite.texture = texture
	sprite.position = position
	sprite.scale = scale
	sprite.material = ShaderMaterial.new()
	sprite.material.gdshader = prepass_shader
	sprite.material.set_shader_parameter("glow_color", glow_color)
	prepass_viewport.add_child(sprite)
	#remote_transform.remote_path = sprite.get_path()
