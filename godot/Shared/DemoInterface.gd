@tool
extends Control

@export_multiline var text_bbcode := "": set = set_text_bbcode

@onready var _rich_text_label: RichTextLabel = $MarginContainer/RichTextLabel


func set_text_bbcode(value: String) -> void:
	text_bbcode = value
	if not _rich_text_label:
		await self.ready
	_rich_text_label.text = value
