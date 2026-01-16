extends Node

signal game_finished
signal update_points(points)
signal update_streak(reset)

@export var scene_6_pizza: PackedScene  # opcional, solo si prefieres instanciar desde script
@export var allowed_denominators: Array = [2, 3, 6, 12]  # denominadores permitidos
@export var debug_print_statuses: bool = false

var rng: RandomNumberGenerator = RandomNumberGenerator.new()
var numerator: int = 1
var denominator: int = 1
var _validate_call_id: int = 0

# Flag para evitar emisiones repetidas de la señal
var _game_finished_emitted: bool = false

func _ready() -> void:
	rng.randomize()
	generate_fraction()
	print("Fracción generada: %d / %d" % [numerator, denominator])

	# Reset del flag por si se reutiliza el nodo
	_game_finished_emitted = false

	var pizza_node := _find_pizza_node()
	if pizza_node == null:
		push_warning("No se encontró '6parts_pizza' como hijo del nodo Equivalence. Comprueba el nombre o asigna scene_6_pizza.")
		return

	var fraction_card := _find_fraction_card()
	if fraction_card == null:
		push_warning("No se encontró 'FractionCard' como hijo del nodo Equivalence.")
	else:
		_update_fraction_card(fraction_card)

	_setup_buttons_for_pizza(pizza_node)


# Genera una fracción propia (1..denominator-1) usando los denominadores permitidos
func generate_fraction() -> void:
	assert(allowed_denominators.size() > 0)
	var index := rng.randi_range(0, allowed_denominators.size() - 1)
	denominator = int(allowed_denominators[index])
	if denominator == 12:
		numerator = rng.randi_range(1, 6) * 2
	else:
		numerator = rng.randi_range(1, denominator - 1)
	# si vuelves a generar durante el juego, permitir nueva emisión
	_game_finished_emitted = false


# --- Búsqueda de nodos --- #
func _find_pizza_node() -> Node:
	# Primer intento: hijo directo "6parts_pizza"
	if has_node("6parts_pizza"):
		return get_node("6parts_pizza")

	# Búsqueda recursiva por nombre
	var found := _find_node_by_name_recursive(self, "6parts_pizza")
	if found:
		return found

	# Si no aparece la instanciamos 
	if scene_6_pizza != null:
		var inst := scene_6_pizza.instantiate()
		add_child(inst)
		return inst

	return null


func _find_fraction_card() -> Node:
	if has_node("FractionCard"):
		return get_node("FractionCard")
	return _find_node_by_name_recursive(self, "FractionCard")


func _find_node_by_name_recursive(node: Node, target_name: String) -> Node:
	for child in node.get_children():
		if child.name == target_name:
			return child
		var sub := _find_node_by_name_recursive(child, target_name)
		if sub:
			return sub
	return null


# --- Actualizar la FracctionCard --- #
func _update_fraction_card(fraction_card: Node) -> void:
	var num_node := _find_node_by_name_recursive(fraction_card, "Numerator")
	var den_node := _find_node_by_name_recursive(fraction_card, "Denominator")

	if num_node:
		if "text" in num_node:
			num_node.text = str(numerator)
		else:
			num_node.set("text", str(numerator))
	else:
		push_warning("No se encontró el nodo 'Numerator' dentro de FractionCard.")

	if den_node:
		if "text" in den_node:
			den_node.text = str(denominator)
		else:
			den_node.set("text", str(denominator))
	else:
		push_warning("No se encontró el nodo 'Denominator' dentro de FractionCard.")


# --- Hijos directos --- #
func _setup_buttons_for_pizza(pizza_node: Node) -> void:
	var buttons: Array = []
	_gather_texture_buttons_direct(pizza_node, buttons)

	if buttons.size() == 0:
		push_warning("No se encontraron TextureButton directos dentro de '6parts_pizza'. Comprueba la estructura.")
		return

	# Ordenar 
	var buttons_sorted = buttons.duplicate()
	buttons_sorted.sort_custom(Callable(self, "_sort_nodes_by_name"))

	var base_handler := Callable(self, "_on_pizza_button_toggled")

	for btn in buttons_sorted:
		if not (btn is TextureButton):
			continue

		if not btn.toggle_mode:
			push_warning("El botón '%s' no tiene toggle_mode activado. Actívalo en el editor." % btn.name)

		# Creamos un Callable ligado con la pizza y el botón
		var bound_handler := base_handler.bind(pizza_node, btn)

		# Desconectar si ya existe esa conexión ligada
		if btn.is_connected("toggled", bound_handler):
			btn.disconnect("toggled", bound_handler)

		# Conectar pasando únicamente el Callable ligado
		btn.connect("toggled", bound_handler)

	# Estado inicial
	var active := _count_active_buttons_in_node(pizza_node, false)
	var active_names := _get_active_button_names(pizza_node)
	print("Botones encendidos iniciales: %d de %d. Activos: %s" % [active, buttons_sorted.size(), str(active_names)])

	# Validación 
	_validate_fraction_against_pizza(pizza_node)


func _gather_texture_buttons_direct(node: Node, out_array: Array) -> void:
	# Solo hijos directos (evita duplicados)
	for child in node.get_children():
		if child is TextureButton:
			out_array.append(child)


func _sort_nodes_by_name(a: Node, b: Node) -> int:
	if a.name < b.name:
		return -1
	elif a.name > b.name:
		return 1
	return 0


# Contar usando is_pressed() si está disponible
func _count_active_buttons_in_node(node: Node, debug_print: bool=false) -> int:
	var buttons: Array = []
	_gather_texture_buttons_direct(node, buttons)
	var cnt := 0
	for b in buttons:
		var pressed_state := false
		if "is_pressed" in b:
			pressed_state = b.is_pressed()
		else:
			pressed_state = bool(b.pressed)

		if pressed_state:
			cnt += 1

		if debug_print_statuses or debug_print:
			print("  (debug) botón:", b.name, "pressed:", pressed_state, "instance_id:", str(b.get_instance_id()))

	return cnt


func _get_active_button_names(node: Node) -> Array:
	var buttons: Array = []
	_gather_texture_buttons_direct(node, buttons)
	var names := []
	for b in buttons:
		var pressed_state := false
		if "is_pressed" in b:
			pressed_state = b.is_pressed()
		else:
			pressed_state = bool(b.pressed)
		if pressed_state:
			names.append(b.name)
	return names


# --- Validación en consola --- #
func _validate_fraction_against_pizza(pizza_node: Node) -> bool:
	var buttons: Array = []
	_gather_texture_buttons_direct(pizza_node, buttons)
	var slices_count := buttons.size()
	if slices_count == 0:
		print("Validación: no se detectaron slices en la pizza.")
		return false

	var expected_f := float(numerator) * float(slices_count) / float(denominator)
	var expected_round := int(round(expected_f))
	var exact_integer := is_equal_approx(expected_f, float(expected_round))

	var active := _count_active_buttons_in_node(pizza_node, false)

	# Mensaje de consola detallado y emisión de señal si es correcto (solo una vez)
	if exact_integer:
		if active == expected_round:
			print("Validación: esperado %d (exacto). Activos: %d -> Correcto." % [expected_round, active])
			# Emitir señal solo una vez
			if not _game_finished_emitted:
				_game_finished_emitted = true
				emit_signal("game_finished")
				emit_signal("update_points", 10)
				emit_signal("update_streak", false)
				print("Se emitió la señal 'game_finished'.")
			return true
		else:
			print("Validación: esperado %d (exacto). Activos: %d -> Incorrecto." % [expected_round, active])
			return false
	else:
		# No representable exactamente en el número de slices actual
		print("Validación: esperado %g (no entero sobre %d slices). Activos: %d -> Incorrecto." % [expected_f, slices_count, active])
		return false


func _on_pizza_button_toggled(pressed: bool, pizza_node: Node, btn: Node) -> void:
	# evento
	print("Botón '%s' cambió (pressed=%s) (evento)." % [btn.name, str(pressed)])

	# Contamos y mostramos estados (debug activable)
	var active := _count_active_buttons_in_node(pizza_node, debug_print_statuses)
	var arr: Array = []
	_gather_texture_buttons_direct(pizza_node, arr)
	var total := arr.size()
	print("Activos ahora: %d de %d" % [active, total])

	# Validación automática (solo consola) — emitirá game_finished si corresponde
	_validate_call_id += 1
	var this_id := _validate_call_id
	await get_tree().create_timer(1.2).timeout
	if this_id != _validate_call_id:
		return 
	_validate_fraction_against_pizza(pizza_node)



# @export var scene_5: PackedScene
# @export var scene_6: PackedScene
# @export var scene_8: PackedScene
#
# func get_scene_for_denominator(d: int) -> PackedScene:
#     match d:
#         5: return scene_5
#         6: return scene_6
#         8: return scene_8
#     return null
#
#
# var scene = get_scene_for_denominator(denominator)
# if scene:
#     var inst = scene.instantiate()
#     add_child(inst)
# 
