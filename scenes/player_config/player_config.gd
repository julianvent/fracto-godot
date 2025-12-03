extends Control

@export var group: ButtonGroup
var gender: String = ""        # código: "M", "F", "N"
var alias: String = ""


func _ready():
	for button in group.get_buttons():
		button.pressed.connect(Callable(_on_gender_pressed).bind(button.text))


func _on_back_pressed():
	SceneManager.change_scene(SceneManager.SCENES.SESSION_MENU)


func _on_gender_pressed(label: String):
	match label:
		"Masculino":
			gender = "M"
		"Femenino":
			gender = "F"
		"Prefiero no decirlo":
			gender = "N"
		_:
			gender = ""


func _on_play_pressed():
	alias = $Alias.text.strip_edges()
	
	# Si el usuario no eligió género, lo consideramos como "Prefiero no decirlo"
	var gender_code := gender
	if gender_code == "":
		gender_code = "N"
	
	# Guardamos también en Global por si lo usas en otra parte
	Global.player_gender = gender_code
	Global.player_name = alias
	
	# Registrar jugador en la sesión activa de StatsManager
	StatsManager.add_player_to_active_session(alias, gender_code)
	
	# Limpiar error visual si lo estabas usando
	$GenderError.visible = false
	
	# Ir al gestor de minijuegos
	SceneManager.change_scene(SceneManager.SCENES.GAME_MANAGER)
