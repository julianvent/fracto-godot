extends Node

@export var card_scene: PackedScene

@onready var fraction_cards = $FractionCards

var generator: FractionGenerator

func _ready():
	generator = FractionGenerator.new()
	add_child(generator)
	_start_round()

func _on_tick_timer_timeout() -> void:
	$HUD.update_timer()

func _start_round():
	var fractions = generator.random_unique_even_fractions(3)
	
	var rng = RandomNumberGenerator.new()
	rng.randomize()
	var card_order = fractions.duplicate()
	card_order.shuffle()
	
	for fraction in card_order:
		var card = card_scene.instantiate()
		card.set_fraction(fraction)
		fraction_cards.add_child(card)
		
