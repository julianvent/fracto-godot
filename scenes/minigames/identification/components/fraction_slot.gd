extends Control

var animate = true

func _can_drop_data(at_position: Vector2, data: Variant):
	return true
	
func _drop_data(at_position: Vector2, data: Variant):
	if not animate:
		data.reparent(self)
		data.position = (size - data.size) / 2
	else:
		if data.has_method("return_to_original"):
			data.return_to_original()
