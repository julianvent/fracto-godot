extends Node

@export var scene_6_pizza: PackedScene
@export var scene_8_pizza: PackedScene

# Denominadores permitidos:
var allowed_denominators: Array = [2,3,4,6,8]
@export var pizza_position: Vector2 = Vector2(275, -275)
var rng: RandomNumberGenerator = RandomNumberGenerator.new()
var numerator: int = 1
var denominator: int = 1

func _ready() -> void:
	rng.randomize()
	generate_fraction()
	print("Fracción generada: %d / %d" % [numerator, denominator])
	var pizza_instance = spawn_pizza_for_denominator(denominator)
	if pizza_instance:
		_setup_buttons_for_pizza(pizza_instance)


func generate_fraction() -> void:
	assert(allowed_denominators.size() > 0)
	var index := rng.randi_range(0, allowed_denominators.size() - 1)
	denominator = int(allowed_denominators[index])
	numerator = rng.randi_range(1, denominator-1)


# Instanciamiento de la pizza
func spawn_pizza_for_denominator(d: int) -> Node:
	var scenes = {
		6: scene_6_pizza,
		8: scene_8_pizza
	}

	# Selección de pizza correcta
	var candidates: Array = []
	for parts in scenes.keys():
		var sc: PackedScene = scenes[parts]
		if sc != null and parts >= d:
			candidates.append(parts)

	var pick_idx = rng.randi_range(0, candidates.size() - 1)
	var chosen_parts = candidates[pick_idx]
	var chosen_scene: PackedScene = scenes[chosen_parts]
	var inst = chosen_scene.instantiate()
	add_child(inst)

	# Llamada a metodo para posicionar pizza
	_position_control_root(inst, pizza_position)

	print("Instanciada pizza de %d piezas en %s" % [chosen_parts, pizza_position])
	return inst


# Metodo posicion pizza
func _position_control_root(inst: Node, pos: Vector2) -> void:
	if inst is Node2D:
		inst.position = pos
		return

	if inst is Control:
		var pos_i := Vector2i(int(pos.x), int(pos.y))
		inst.rect_position = pos_i
		return

	# Si la raíz no es Control ni Node2D
	var ctrl = inst.get_node_or_null("Control")
	if ctrl and (ctrl is Control):
		ctrl.rect_position = Vector2i(int(pos.x), int(pos.y))
		return

	# Si no existe "Control", buscamos el primer Control recursivamente
	ctrl = _find_first_control_recursive(inst)
	if ctrl:
		ctrl.rect_position = Vector2i(int(pos.x), int(pos.y))
		return 
	push_warning("No se encontró un nodo Control o Node2D para posicionar la pizza instanciada.")


func _find_first_control_recursive(node: Node) -> Control:
	for child in node.get_children():
		if child is Control:
			return child
		var found = _find_first_control_recursive(child)
		if found:
			return found
	return null

#Botones
func _setup_buttons_for_pizza(pizza_node: Node) -> void:
	var buttons = []
	_gather_texture_buttons_recursive(pizza_node, buttons)

	# Conectar cada botón para que actualice el conteo
	for btn in buttons:
		# Evitar conteos dobles
		if not btn.is_connected("toggled", Callable(self, "_on_pizza_button_toggled")):
			btn.connect("toggled", Callable(self, "_on_pizza_button_toggled"), [pizza_node])
			
	var active = _count_active_buttons_in_node(pizza_node)
	print("Botones encendidos iniciales:", active, "de", buttons.size())


func _gather_texture_buttons_recursive(node: Node, out_array: Array) -> void:
	for child in node.get_children():
		if child is TextureButton:
			out_array.append(child)
		_gather_texture_buttons_recursive(child, out_array)


func _count_active_buttons_in_node(node: Node) -> int:
	var buttons = []
	_gather_texture_buttons_recursive(node, buttons)
	var cnt := 0
	for b in buttons:
		if b.pressed:
			cnt += 1
	return cnt


func _on_pizza_button_toggled(pressed: bool, pizza_node: Node) -> void:
	var active = _count_active_buttons_in_node(pizza_node)
	var total = 0
	var arr = []
	_gather_texture_buttons_recursive(pizza_node, arr)
	total = arr.size()
	print("Botón cambiado (pressed=%s). Activos ahora: %d de %d" % [str(pressed), active, total])


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
