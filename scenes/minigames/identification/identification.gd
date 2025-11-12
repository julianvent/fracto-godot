extends Node

signal card_placed(correct)

@export var card_scene: PackedScene
@export var slot_scene: PackedScene
@export var pizza_scene: PackedScene

@onready var fraction_cards = $FractionCards
@onready var fraction_slots = $FractionContainer/FractionSlots

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
	
	for fraction in fractions:
		print(fraction)
		var slot = slot_scene.instantiate()
		var pizza = pizza_scene.instantiate()
		slot.set_fraction(fraction)
		pizza.set_fraction(fraction)
		pizza.size = Vector2(250.0, 250.0)
		
		var fractionPizzaHBox = HBoxContainer.new()
		fractionPizzaHBox.add_theme_constant_override("separation", 150)
		fraction_slots.add_child(fractionPizzaHBox)
		
		fractionPizzaHBox.add_child(slot)
		fractionPizzaHBox.add_child(pizza)
		fractionPizzaHBox.size_flags_horizontal = Control.SIZE_SHRINK_CENTER
		fractionPizzaHBox.alignment = BoxContainer.ALIGNMENT_CENTER
		
		slot.connect("dropped_card", Callable(self, "_on_slot_dropped"))
	
	for fraction in card_order:
		var card = card_scene.instantiate()
		card.set_fraction(fraction)
		fraction_cards.add_child(card)
		
		
func _on_slot_dropped(card_node, correct):
	emit_signal("card_placed", correct)
