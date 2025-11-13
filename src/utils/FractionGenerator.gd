extends Node

class_name FractionGenerator

@export_range(2, 8)
var min_denominator: int = 2
@export_range(2, 8)
var max_denominator: int = 8

var rng: RandomNumberGenerator

func _init():
	rng = RandomNumberGenerator.new()
	rng.randomize()
	
func _even_denominators_in_range():
	var lo = min(min_denominator, max_denominator)
	var hi = max(min_denominator, max_denominator)
	
	var evens = []
	
	for number in range(lo, hi + 1):
		if number % 2 == 0:
			evens.append(number)
			
	if evens.is_empty():
		evens.append(2)
	
	return evens
	
func random_even_fraction():
	var evens = _even_denominators_in_range()
	var denominator = evens[rng.randi_range(0, evens.size() - 1)]
	
	var numerator_min = 1
	var numerator_max = denominator - 1
	var numerator = rng.randi_range(numerator_min, numerator_max)
	
	var reduced = FractionUtils.reduce_fraction(numerator, denominator)
	
	return {"numerator": numerator, "denominator": denominator, "reduced": reduced}
	
func random_unique_even_fractions(count: int):
	var fractions = []
	var attempts = 0
	
	while fractions.size() < count and attempts < 500:
		attempts += 1
		var fraction = random_even_fraction()
		if not fractions.any(func(x): return FractionUtils.fractions_equal(x, fraction)):
			fractions.append(fraction)
			
	return fractions
	
