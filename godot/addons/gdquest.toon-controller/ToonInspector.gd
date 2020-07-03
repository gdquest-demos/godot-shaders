class_name ToonInspector
extends EditorInspectorPlugin

func can_handle(object: Object) -> bool:
	if object is ToonSceneBuilder:
		var button := Button.new()
		button.text = "??"
		
		
		return true
	else:
		return false

