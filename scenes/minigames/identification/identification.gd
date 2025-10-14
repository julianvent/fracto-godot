extends Node

func _on_tick_timer_timeout() -> void:
	$HUD.update_timer()
