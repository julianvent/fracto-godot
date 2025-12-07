extends Node

func _ready():
	call_deferred("mostrar_cartas_opciones")


func random_fraction() -> Dictionary:
	var rng = RandomNumberGenerator.new()
	rng.randomize()
	var denominator = rng.randi_range(2, 6)
	var numerator = rng.randi_range(1, denominator)
	var divisor = maximo_comun_divisor(numerator, denominator)
	return {
		"numerator": int(numerator / divisor),
		"denominator": int(denominator / divisor),
		"reduced": {
			"numerator": int(numerator / divisor),
			"denominator": int(denominator / divisor)
		}
	}

func maximo_comun_divisor(a: int, b: int) -> int:
	while b != 0:
		var temp = b
		b = a % b
		a = temp
	return abs(a)

func sum_fractions(frac1: Dictionary, frac2: Dictionary) -> Dictionary:
	var num1 = frac1["numerator"]
	var den1 = frac1["denominator"]
	var num2 = frac2["numerator"]
	var den2 = frac2["denominator"]
	
	print("Fracción 1: %s/%s, Fracción 2: %s/%s" % [
	frac1["numerator"], frac1["denominator"],
	frac2["numerator"], frac2["denominator"]
	])

	var suma_numerador = num1 * den2 + num2 * den1
	var suma_denominador = den1 * den2

	var divisor = maximo_comun_divisor(suma_numerador, suma_denominador)
	var reduced_numerador = int(suma_numerador / divisor)
	var reduced_denominator = int(suma_denominador / divisor)
	return {
		"numerator": reduced_numerador,
		"denominator": reduced_denominator,
		"reduced": {
			"numerator": reduced_numerador,
			"denominator": reduced_denominator
		}
	}

func is_fraction_equal(f1: Dictionary, f2: Dictionary) -> bool:
	return f1["numerator"] == f2["numerator"] and f1["denominator"] == f2["denominator"]

func contains_fraction(array: Array, frac: Dictionary) -> bool:
	for f in array:
		if is_fraction_equal(f, frac):
			return true
	return false

func mostrar_cartas_opciones():
	# Fracciones desde addition_container (PanelContainer)
	var fraction_container = $BG/PanelContainer
	var fraction1 = fraction_container.fraction1
	var fraction2 = fraction_container.fraction2

	# FRaccion correcta
	var correct_frac = sum_fractions(fraction1, fraction2)

	# Fracciones incorrectas
	var options := [correct_frac]
	while options.size() < 3:
		var distractor = random_fraction()
		if not is_fraction_equal(distractor, correct_frac) and not contains_fraction(options, distractor):
			options.append(distractor)

	options.shuffle() # Aleatorio


	var card_nodes = [
		$BG/fractions_container/HBoxContainer/FractionCard,
		$BG/fractions_container/HBoxContainer/FractionCard2,
		$BG/fractions_container/HBoxContainer/FractionCard3
	]
	# Asigna cada fracción
	for i in range(card_nodes.size()):
		card_nodes[i].set_fraction(options[i])
	
	$BG/FractionSlot.set_fraction(correct_frac)
	
	print("Fracción correcta: %s/%s (Reducida: %s/%s)" % [
		correct_frac["numerator"], correct_frac["denominator"],
		correct_frac["reduced"]["numerator"], correct_frac["reduced"]["denominator"]
	])
	
