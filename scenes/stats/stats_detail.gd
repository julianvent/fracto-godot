extends Control

@onready var header_label: Label = $MarginContainer/MainVBox/HeaderCard/HeaderVBox/HeaderLabel
@onready var total_label: Label  = $MarginContainer/MainVBox/CountsVBox/TotalLabel
@onready var masc_label: Label   = $MarginContainer/MainVBox/CountsVBox/MascLabel
@onready var fem_label: Label    = $MarginContainer/MainVBox/CountsVBox/FemLabel
@onready var nd_label: Label     = $MarginContainer/MainVBox/CountsVBox/NDLabel


func _ready() -> void:
	_load_session_data()


func _load_session_data() -> void:
	var session: Dictionary = StatsManager.current_session
	if session.is_empty():
		SceneManager.change_scene(SceneManager.SCENES.STATS_MENU)
		return

	var counts: Dictionary = StatsManager.get_session_counts(session)

	var school: String = session.get("school", "")
	var group: String  = session.get("group", "")
	var date: String   = session.get("date", "")

	# -------- Encabezado: escuela + grupo en la tarjeta morada --------
	var linea_superior: String = school
	if group != "":
		if linea_superior != "":
			linea_superior += " "
		linea_superior += group

	var header_text: String = linea_superior
	if date != "":
		if header_text != "":
			header_text += "\n"
		header_text += date

	header_label.text = header_text

	# -------- Conteos --------
	total_label.text = "%d jugadores" % counts["total"]
	masc_label.text  = "%d masculinos" % counts["M"]
	fem_label.text   = "%d femeninas" % counts["F"]
	nd_label.text    = "%d prefiero no decirlo" % counts["N"]


func _on_export_button_pressed() -> void:
	var path = StatsManager.export_session_to_csv(StatsManager.current_session)
	print("CSV exportado en:", path)


func _on_back_button_pressed() -> void:
	SceneManager.change_scene(SceneManager.SCENES.STATS_MENU)
