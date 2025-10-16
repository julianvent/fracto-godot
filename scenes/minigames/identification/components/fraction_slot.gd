extends Control

func _can_drop_data(at_position: Vector2, data: Variant):
	return true
	
func _drop_data(at_position: Vector2, data: Variant):
	data.reparent(self)
	data.position = (size - data.size) / 2
