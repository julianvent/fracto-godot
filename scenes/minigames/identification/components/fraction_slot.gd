extends Control

@export var points_reward = 10
@export var floating_points_scene: PackedScene

signal dropped_card(correct)

var original_fraction := {"numerator": 1, "denominator": 2}
var reduced_fraction := {"numerator": 1, "denominator": 2}
var _is_card_placed = false


func set_fraction(fraction):
	original_fraction.numerator = int(fraction.numerator)
	original_fraction.denominator = int(fraction.denominator)
	reduced_fraction = fraction.reduced
	

func _can_drop_data(at_position: Vector2, data: Variant):
	if _is_card_placed:
		return false
	
	if typeof(data) != TYPE_DICTIONARY:
		return false
	
	return data.has("fraction")

func _drop_data(at_position: Vector2, data: Variant):
	if (typeof(data) != TYPE_DICTIONARY):
		return
	if not data.has("fraction") or not data.has("card_reference"):
		return
	
	var card = data.card_reference
	var dropped_reduced = data.reduced_fraction
		
	var correct = FractionUtils.fractions_equal(dropped_reduced, reduced_fraction)
	if card and is_instance_valid(card):
		if correct:
			card.place_in_slot(self)
			_is_card_placed = true
			_show_points(points_reward, at_position)
		
		emit_signal("dropped_card", correct)
			

func _show_points(points: int, local_pos: Vector2) -> void:
	var floating_points = floating_points_scene.instantiate()
	add_child(floating_points)
	floating_points.play(points, local_pos)
