extends Control

var original_fraction := {"numerator": 1, "denominator": 2}
var reduced_fraction := {"numerator": 1, "denominator": 2}

func set_fraction(fraction):
	original_fraction.numerator = int(fraction.numerator)
	original_fraction.denominator = int(fraction.denominator)
	reduced_fraction = fraction.reduced
	

func _can_drop_data(at_position: Vector2, data: Variant):
	if typeof(data) != TYPE_DICTIONARY:
		return false
	return data.has("fraction")

func _drop_data(at_position: Vector2, data: Variant):
	if (typeof(data) != TYPE_DICTIONARY):
		return
	if not data.has("fraction") or not data.has("card_reference"):
		return
		
	print(data)
	
	var card = data.card_reference
	var dropped_reduced = data.reduced_fraction
		
	var correct = FractionUtils.fractions_equal(dropped_reduced, reduced_fraction)
	if card and is_instance_valid(card):
		if correct:
			card.place_in_slot(self)
