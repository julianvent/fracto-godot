extends Control

var original_fraction := {"numerator": 1, "denominator": 2}
var reduced_fraction := {"numerator": 1, "denominator": 2}

var animate = true

func set_fraction(fraction):
	original_fraction.numerator = int(fraction.numerator)
	original_fraction.denominator = int(fraction.denominator)
	
	reduced_fraction = fraction.reduced

func _can_drop_data(at_position: Vector2, data: Variant):
	return true
	
func _drop_data(at_position: Vector2, data: Variant):
	if not animate:
		data.reparent(self)
		data.position = (size - data.size) / 2
	else:
		if data.has_method("return_to_original"):
			data.return_to_original()
