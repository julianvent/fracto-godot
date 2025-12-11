extends Control


@onready var header_label: Label = $MarginContainer/MainVBox/HeaderCard/HeaderVBox/HeaderLabel

@onready var total_label: Label = $MarginContainer/MainVBox/HeaderCard/HeaderVBox/CountsVBox/TotalRow/TotalLabel
@onready var masc_label: Label  = $MarginContainer/MainVBox/HeaderCard/HeaderVBox/CountsVBox/MascRow/MascLabel
@onready var fem_label: Label   = $MarginContainer/MainVBox/HeaderCard/HeaderVBox/CountsVBox/FemRows/FemLabel
@onready var nd_label: Label    = $MarginContainer/MainVBox/HeaderCard/HeaderVBox/CountsVBox/HBoxContainer/NDLabel


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

	total_label.text = "%d jugadores" % counts["total"]
	masc_label.text  = "%d masculinos" % counts["M"]
	fem_label.text   = "%d femeninas" % counts["F"]
	nd_label.text    = "%d prefiero no decirlo" % counts["N"]


func _on_export_button_pressed() -> void:
	if OS.get_name() == "Android":
		OS.request_permissions()

	var path := StatsManager.export_session_to_csv(StatsManager.current_session)

	if path == "":
		_show_message(
			"No se pudo exportar el archivo CSV.\nRevisa permisos o vuelve a intentar.",
			true
		)
	else:
		var msg: String
		if OS.get_name() == "Android":
			msg = "Archivo CSV exportado con éxito.\n" \
				+ "Lo encontrarás en:\nDescargas/Fracto"
		else:
			msg = "Archivo CSV exportado con éxito.\nUbicación:\n" + path

		_show_message(msg)


func _on_back_button_pressed() -> void:
	SceneManager.change_scene(SceneManager.SCENES.STATS_MENU)


func _show_message(text: String, is_error: bool = false) -> void:
	var dialog := AcceptDialog.new()
	dialog.title = "Error al exportar" if is_error else "Exportar CSV"
	dialog.dialog_text = text
	add_child(dialog)
	dialog.popup_centered()
