extends Control

signal on_continue()

func _on_continue_pressed() -> void:
	emit_signal("on_continue")
