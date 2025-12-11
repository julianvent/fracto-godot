extends Control

@onready var list_container: VBoxContainer = $MarginContainer/MainVBox/SessionsScroll/SessionsList
@onready var session_item_scene: PackedScene = preload("res://scenes/stats/session_item.tscn")

@onready var filter_by_date_button: Button = $MarginContainer/MainVBox/FiltersHBox/FilterByDateButton
@onready var filter_by_school_button: Button = $MarginContainer/MainVBox/FiltersHBox/FilterBySchoolButton

var all_sessions: Array = []
var sort_mode: String = "date" # "date" o "school"


func _ready() -> void:
	all_sessions = StatsManager.get_sessions_for_current_user()
	_refresh_list()
	_update_filter_buttons()
	


# Rellenar la lista según el filtro activo
func _refresh_list() -> void:
	for child in list_container.get_children():
		child.queue_free()

	if all_sessions.is_empty():
		return

	var sessions: Array = all_sessions.duplicate()

	# Ordenar según el modo actual
	match sort_mode:
		"date":
			sessions.sort_custom(Callable(self, "_sort_by_date_desc"))
		"school":
			sessions.sort_custom(Callable(self, "_sort_by_school"))

	# Crear ítems
	for s in sessions:
		var item = session_item_scene.instantiate()
		item.setup(s)
		item.session_pressed.connect(_on_session_item_pressed)
		list_container.add_child(item)


# Ordenar de más nueva a más vieja 
func _sort_by_date_desc(a: Dictionary, b: Dictionary) -> bool:
	var da: String = a.get("date", "")
	var db: String = b.get("date", "")
	return da > db  


# Ordenar alfabéticamente por escuela
func _sort_by_school(a: Dictionary, b: Dictionary) -> bool:
	var sa: String = a.get("school", "")
	var sb: String = b.get("school", "")
	return sa < sb


# Botones de filtro
func _on_filter_by_date_button_pressed() -> void:
	sort_mode = "date"
	_refresh_list()
	_update_filter_buttons()


func _on_filter_by_school_button_pressed() -> void:
	sort_mode = "school"
	_refresh_list()
	_update_filter_buttons()


func _update_filter_buttons() -> void:
	if sort_mode == "date":
		filter_by_date_button.modulate = Color(1, 1, 1, 1)
		filter_by_school_button.modulate = Color(0.85, 0.85, 0.85, 1)
	else:
		filter_by_date_button.modulate = Color(0.85, 0.85, 0.85, 1)
		filter_by_school_button.modulate = Color(1, 1, 1, 1)


func _on_session_item_pressed(session: Dictionary) -> void:
	StatsManager.set_current_session(session)
	SceneManager.change_scene(SceneManager.SCENES.STATS_DETAIL)


func _on_back_button_pressed() -> void:
	SceneManager.change_scene(SceneManager.SCENES.MAIN_MENU)
