extends Node

class_name FractionUtils

static func gcd(a: int, b: int):
	if a == 0:
		return abs(b)
	
	a = abs(a)
	b = abs(b)
	
	while b != 0:
		var t = b
		b = a % b
		a = t
	return a
	
static func reduce_fraction(numerator: int, denominator: int):
	if denominator == 0:
		push_error("Denominator cannot be zero")
		return {"numerator": 0, "denominator": 1}
		
	var g = gcd(numerator, denominator)
	
	numerator /= g
	denominator /= g
	
	return {"numerator": int(numerator), "denominator": int(denominator)}
	

static func fractions_equal(a, b):
	var reduced_fraction_a = reduce_fraction(a.numerator, a.denominator)
	var reduced_fraction_b = reduce_fraction(b.numerator, b.denominator)
	
	return reduced_fraction_a.numerator == reduced_fraction_b.numerator and reduced_fraction_a.denominator == reduced_fraction_b.denominator
