extends Label

@export var duration = 0.8
@export var move_distance = 40.0


func _ready() -> void:
	modulate.a = 1.0
	

func play(points, local_pos):
	text = "+" + str(points)
	
	position = local_pos - Vector2(0, 40)
	
	var t = create_tween()
	var start_y = position.y
	var end_y = start_y - move_distance
	
	t.tween_property(self, "position:y", end_y, duration).set_trans(Tween.TRANS_SINE).set_ease(Tween.EASE_OUT)
	t.tween_property(self, "modulate:a", 0.0, duration)
	t.connect("finished", Callable(self, "_on_tween_completed"))
	
func _on_tween_completed():
	queue_free()

	
