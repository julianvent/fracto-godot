extends Control

# Ruta a la escena del trozo de pizza
const PIZZA_SLICE_SCENE = preload("res://PizzaSlice.tscn")

# Nodos de UI
@onready var fraction_label_numerator: Label = $FractionContainer/NumeratorLabel
@onready var fraction_label_denominator: Label = $FractionContainer/DenominatorLabel
@onready var pizza_container: Node2D = $PizzaContainer

# Variables del juego
var required_numerator: int
var required_denominator: int
var slice_multiplier: int
var total_slices: int
var selected_slices: int = 0
var slices: Array[Node] = [] # Almacena todas las instancias de PizzaSlice

# --- Lógica de Inicio ---

func _ready():
	start_new_round()

# Inicia una nueva ronda de juego
func start_new_round():
	# 1. Generar la Fracción y el Multiplicador
	generate_problem()
	
	# 2. Actualizar la UI de la fracción
	update_fraction_ui()
	
	# 3. Generar la Pizza
	generate_pizza()

# Genera una fracción aleatoria y el número total de trozos
func generate_problem():
	# Denominador de 2 a 8
	required_denominator = randi_range(2, 8)
	# Numerador de 1 a (denominador - 1)
	required_numerator = randi_range(1, required_denominator - 1)
	
	# Multiplicador del número de trozos (1 a 3)
	slice_multiplier = randi_range(1, 3)
	total_slices = required_denominator * slice_multiplier
	
	print("Fracción requerida: %d/%d" % [required_numerator, required_denominator])
	print("Pizza dividida en: %d trozos" % total_slices)
	
func update_fraction_ui():
	fraction_label_numerator.text = str(required_numerator)
	fraction_label_denominator.text = str(required_denominator)

# Genera los trozos de pizza en el contenedor
func generate_pizza():
	# Limpiar trozos anteriores
	for slice in slices:
		slice.queue_free()
	slices.clear()
	
	selected_slices = 0
	
	# Centro de la pizza (asume que pizza_container está en el centro)
	var center_pos = Vector2(0, 0) # Ajusta esto a la posición real del centro
	var slice_angle = 360.0 / total_slices # Ángulo de cada trozo

	for i in range(total_slices):
		var slice_instance = PIZZA_SLICE_SCENE.instantiate()
		pizza_container.add_child(slice_instance)
		
		# Configurar y conectar el trozo
		slice_instance.index = i
		slice_instance.slice_toggled.connect(_on_pizza_slice_toggled)
		slices.append(slice_instance)
		
		# Posicionamiento: Rotar el trozo
		# El diseño del trozo debe estar centrado en su pivote y apuntar hacia arriba (rotación 0)
		# Luego se rota para formar el círculo.
		slice_instance.rotation_degrees = i * slice_angle
		# Si usas Polygon2D, el cálculo de los vértices y la rotación es más complejo. 
		# Esta es solo una aproximación para posicionar.

# --- Lógica de Interacción y Verificación ---

# Se llama cada vez que un trozo cambia su estado
func _on_pizza_slice_toggled(_index: int, is_selected_now: bool):
	if is_selected_now:
		selected_slices += 1
	else:
		selected_slices -= 1
		
	print("Trozo %d, Seleccionado: %s. Total seleccionados: %d" % [_index, is_selected_now, selected_slices])
	
	# Verificar si la respuesta es correcta
	check_answer()

# Comprueba si la fracción de trozos seleccionados es igual a la fracción requerida
func check_answer():
	# La cantidad de trozos correctos es: (Fracción Requerida) * (Total de Trozos)
	var correct_number_of_slices = required_numerator * slice_multiplier
	
	# La fracción seleccionada es selected_slices / total_slices
	# Si selected_slices == correct_number_of_slices, es correcto.
	
	if selected_slices == correct_number_of_slices:
		print("¡Respuesta Correcta!")
		# Implementar lógica de puntuación y pasar a la siguiente ronda
		await get_tree().create_timer(1.0).timeout # Espera 1 segundo
		start_new_round()
	elif selected_slices > correct_number_of_slices:
		# Opcional: penalizar o no permitir más selección
		print("¡Demasiados trozos seleccionados!")
