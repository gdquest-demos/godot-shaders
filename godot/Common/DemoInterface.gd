tool
extends Control

export(String, MULTILINE) var text_bbcode := "" setget set_text_bbcode

onready var rich_text_label := $RichTextLabel


func set_text_bbcode(value: String) -> void:
	text_bbcode = value
	if not rich_text_label:
		yield(self, "ready")
	rich_text_label.bbcode_text = value
