extends TextureButton

# Señal que se emite cuando se presiona el trozo
signal slice_toggled(slice_index: int, is_selected: bool)

var index: int = 0
var is_selected: bool = false
const COLOR_UNSELECTED = Color.GRAY
const COLOR_SELECTED = Color.YELLOW

@onready var sprite = $Sprite2D #

# Inicia el estado del trozo
func _ready():
	self.pressed.connect(_on_pressed)
	update_visuals()

func _on_pressed():
	toggle_selection()

# Cambia el estado a seleccionado
func toggle_selection():
	is_selected = !is_selected
	update_visuals()
	slice_toggled.emit(index, is_selected)

# Actualiza el color de la porción
func update_visuals():
	if is_selected:
		sprite.modulate = COLOR_SELECTED
	else:
		sprite.modulate = COLOR_UNSELECTED
