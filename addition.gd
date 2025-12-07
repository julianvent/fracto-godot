extends Node

@export var fraction_card_scene: PackedScene

func _ready():
	_generate_options()

func _generate_options():
	# Calcula (o recibe) la fracción correcta
	var correct_fraction = {
		"numerator": 3,   # Ejemplo, pon aquí el correcto
		"denominator": 4,
		"reduced": {"numerator": 3, "denominator": 4}
	}

	# 2. Genera dos fracciones distractoras
	var distractor1 = _random_incorrect_fraction([correct_fraction])
	var distractor2 = _random_incorrect_fraction([correct_fraction, distractor1])

	# 3. Prepara lista, desordena para que el correcto pueda estar en cualquier posición
	var options = [correct_fraction, distractor1, distractor2]
	options.shuffle()

	# 4. Limpia el contenedor antes de agregar cartas nuevas
	for node in $fractions_container.get_children():
		node.queue_free()

	# 5. Genera las cartas
	for fraction in options:
		var card = fraction_card_scene.instantiate()
		card.set_fraction(fraction)
		$fractions_container.add_child(card)

func _random_incorrect_fraction(avoid_fractions: Array) -> Dictionary:
	# Intenta generar una fracción distinta a las que están en avoid_fractions
	var tries = 0
	var max_tries = 100
	var rng = RandomNumberGenerator.new()
	rng.randomize()
	while tries < max_tries:
		var denom = rng.randi_range(1, 8)
		var num = rng.randi_range(0, denom)
		var divisor = gcd(num, denom)
		var reduced = {"numerator": num/divisor, "denominator": denom/divisor}
		var fraction = {
			"numerator": num,
			"denominator": denom,
			"reduced": reduced
		}
		var is_unique = true
		for avoid in avoid_fractions:
			if avoid["reduced"] == fraction["reduced"]:
				is_unique = false
				break
		if is_unique:
			return fraction
		tries += 1
	# Si falla, regresa algo seguro
	return {"numerator": 1, "denominator": 8, "reduced": {"numerator": 1, "denominator": 8}}

func gcd(a: int, b: int) -> int:
	while b != 0:
		var temp = b
		b = a % b
		a = temp
	return abs(a)
