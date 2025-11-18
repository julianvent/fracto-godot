extends Node

@export var card_scene: PackedScene
@export var slot_scene: PackedScene
@export var pizza_scene: PackedScene
@export var cards_to_be_placed = 3
@export var points_per_card = 10
@export var replays = 3

@onready var fraction_cards = $FractionCards
@onready var fraction_slots = $FractionContainer/FractionSlots

@onready var placed_cards = 0
@onready var times_replayed = 0
var generator: FractionGenerator

signal update_points(points)
signal game_finished

func _ready():
	generator = FractionGenerator.new()
	add_child(generator)
	_start_round()

func _on_tick_timer_timeout() -> void:
	$HUD.update_timer()

func _start_round():
	times_replayed += 1
	var fractions = generator.random_unique_even_fractions(3)
	
	var rng = RandomNumberGenerator.new()
	rng.randomize()
	var card_order = fractions.duplicate()
	card_order.shuffle()
	
	for fraction in fractions:
		var slot = slot_scene.instantiate()
		var pizza = pizza_scene.instantiate()
		slot.set_fraction(fraction)
		pizza.set_fraction(fraction)
		
		var fractionPizzaHBox = HBoxContainer.new()
		fractionPizzaHBox.add_theme_constant_override("separation", 150)
		fraction_slots.add_child(fractionPizzaHBox)
		
		fractionPizzaHBox.add_child(slot)
		fractionPizzaHBox.add_child(pizza)
		fractionPizzaHBox.size_flags_horizontal = Control.SIZE_SHRINK_CENTER
		fractionPizzaHBox.alignment = BoxContainer.ALIGNMENT_CENTER
		
		slot.connect("dropped_card", Callable(self, "_on_card_placed"))
	
	for fraction in card_order:
		var card = card_scene.instantiate()
		card.set_fraction(fraction)
		fraction_cards.add_child(card)
		
		
func _on_card_placed(card, is_correct):
	if is_correct:
		placed_cards += 1
		emit_signal("update_points", points_per_card)
		
	if placed_cards == cards_to_be_placed:
		emit_signal("game_finished")
	
