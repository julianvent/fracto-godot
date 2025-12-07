extends Control

@export var pizza_scene: PackedScene          

func _ready():
	_start_round()

func _start_round():
	for node in $HBoxContainer/Control/CenterContainer.get_children():
		node.queue_free()
	for node in $HBoxContainer/Control2/CenterContainer.get_children():
		node.queue_free()

	# Fracciones aleatorias
	var fraction1 = random_fraction()
	var fraction2 = random_fraction()

	# Pizza izquierda
	var pizza1 = pizza_scene.instantiate()
	pizza1.set_fraction(fraction1)
	$HBoxContainer/Control/CenterContainer.add_child(pizza1)

	# Pizza derecha
	var pizza2 = pizza_scene.instantiate()
	pizza2.set_fraction(fraction2)
	$HBoxContainer/Control2/CenterContainer.add_child(pizza2)


func random_fraction() -> Dictionary:
	var rng = RandomNumberGenerator.new()
	rng.randomize()
	var denominator = rng.randi_range(2, 6) #Rangos del denominador
	var numerator = rng.randi_range(1, denominator) #Rangos del numerador
	return {
		"numerator": numerator,
		"denominator": denominator,
		"reduced": {"numerator": numerator, "denominator": denominator}
	}

func maximo_comun_divisor(a: int, b: int) -> int:
	while b != 0:
		var temp = b
		b = a % b
		a = temp
	return abs(a)

func sum_fractions(frac1: Dictionary, frac2: Dictionary) -> Dictionary:
	var numerador1 = frac1["numerator"]
	var denominador1 = frac1["denominator"]
	var numerador2 = frac2["numerator"]
	var denominador2 = frac2["denominator"]

	var suma_numerador = numerador1 * denominador2 + numerador2 * denominador1
	var suma_denominador = denominador1 * denominador2
	
	# Reducción
	var divisor = maximo_comun_divisor(suma_numerador, suma_denominador)
	var reduced_numerador = suma_numerador / divisor
	var reduced_denominador = suma_denominador / divisor

	return {
		"numerator": suma_numerador,
		"denominator": suma_denominador,
		"reduced": {"numerator": reduced_numerador, "denominator": reduced_denominador}
	}
