tool
extends Control


var value := 0xFFFFF
var hovered_index := -1
var flag_rects := []


func _gui_input(event: InputEvent) -> void:
	if event is InputEventMouseMotion:
		for i in flag_rects.size():
			if flag_rects[i].has_point(event.position):
				hovered_index = i
				update()
				break
	if (
		event is InputEventMouseButton and
		event.button_index == BUTTON_LEFT and
		event.pressed
	):
		if value & ( 1 << hovered_index):
			value &= ~(1 << hovered_index)
		else:
			value |= (1 << hovered_index)
		
		emit_signal("flag_changed", value)
		update()


func _notification(what: int) -> void:
	match what:
		NOTIFICATION_DRAW:
			var rect := Rect2()
			rect.size = rect_size
			flag_rects.clear()
			
			var base_size := int((rect.size.y * 80 / 100) / 2)
			var height := int(base_size * 2 + 1)
			var vertical_offset := int((rect.size.y - height) / 2)
			
			var color := get_color("highlight_color", "Editor")
			
			for i in range(2):
				var offset := Vector2(4, vertical_offset)
				if i == 1:
					offset.y += base_size + 1
				
				offset += rect.position
				
				for j in range(10):
					var out := offset + Vector2(j * (base_size + 1), 0)
					if j >= 5:
						out.x += 1
					
					var idx := i * 10 + j
					var on := value & ( 1 << idx)
					var rect2 := Rect2(out, Vector2(base_size, base_size))
					
					color.a = 0.6 if on else 0.2
					
					if idx == hovered_index:
						color.a += 0.15
					
					draw_rect(rect2, color)
					flag_rects.push_back(rect2)

		NOTIFICATION_MOUSE_EXIT:
			hovered_index = -1
			update()
