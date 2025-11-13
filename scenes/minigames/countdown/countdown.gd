extends Control

signal on_finish_countdown()

@export var countdown = 5
@export var go_countdown = 2

@onready var time_label = $Labels/Time
@onready var caption_label = $Labels/Caption


func _ready() -> void:
	time_label.text = str(countdown)


func _on_tick_timer_timeout() -> void:
	if countdown > 0:
		countdown -= 1
	else:
		go_countdown -= 1
		
	_update_timer()

func _update_timer():
	if (countdown > 0):
		time_label.text = str(countdown)
	
	if (countdown == 0):
		caption_label.text = "¡Ya!"
		time_label.hide()
	
	if go_countdown == 0:
		emit_signal("on_finish_countdown")
		queue_free()
