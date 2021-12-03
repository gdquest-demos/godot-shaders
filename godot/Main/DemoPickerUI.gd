class_name DemoPickerUI
extends Control

# warning-ignore:unused_signal
signal demo_requested

var demo_path: String setget set_demo_path

onready var _list := find_node("DemoList")

onready var _load_button := find_node("LoadButton")
onready var _quit_button := find_node("QuitButton")
onready var _help_button := find_node("HelpButton")

onready var _search_bar := find_node("SearchBar")
onready var _search_label := find_node("SearchLabel")

onready var _help_window := find_node("HelpWindow")

onready var _filter_button_container := find_node("FilterButtons")


func _ready() -> void:
	_load_button.connect("pressed", self, "emit_signal", ["demo_requested"])
	_list.connect("demo_selected", self, "set_demo_path")
	_list.connect("demo_requested", self, "emit_signal", ["demo_requested"])
	_list.connect("display_updated", self, "_on_DemoList_display_updated")
	_search_bar.connect("text_entered", self, "_on_LineEdit_text_entered")
	_quit_button.connect("pressed", self, "quit_game")
	_help_button.connect("pressed", _help_window, "show")
	_help_window.connect("gui_input", self, "_on_HelpWindow_gui_input")
	
	_list.setup(_filter_button_container.get_children())


func _input(event: InputEvent) -> void:
	if event.is_action_pressed("search"):
		_search_bar.grab_focus()
	elif event.is_action_pressed("ui_cancel"):
		if _help_window.visible:
			_help_window.hide()
		else:
			_search_bar.clear()


func set_demo_path(value: String) -> void:
	demo_path = value
	_load_button.disabled = demo_path == ""


func quit_game() -> void:
	get_tree().quit()


func _on_LineEdit_text_changed(new_text: String) -> void:
	_search_label.visible = new_text == ""
	_list.update_display(new_text)


func _on_DemoList_display_updated(item_count: int):
	_load_button.disabled = item_count == 0


func _on_HelpWindow_gui_input(event: InputEvent) -> void:
	if event.is_action_pressed("click"):
		_help_window.hide()
