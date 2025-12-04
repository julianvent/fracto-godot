extends Control

@onready var list_container: VBoxContainer = $MarginContainer/MainVBox/SessionsScroll/SessionsList
@onready var session_item_scene: PackedScene = preload("res://scenes/stats/session_item.tscn")


func _ready() -> void:
	_fill_sessions()


func _fill_sessions() -> void:
	# Limpiar lista
	for child in list_container.get_children():
		child.queue_free()

	var sessions: Array = StatsManager.get_sessions_for_current_user()

	if sessions.is_empty():
		return

	for s in sessions:
		var item = session_item_scene.instantiate()
		item.setup(s)
		item.session_pressed.connect(_on_session_item_pressed)
		list_container.add_child(item)


func _on_session_item_pressed(session: Dictionary) -> void:
	StatsManager.set_current_session(session)
	SceneManager.change_scene(SceneManager.SCENES.STATS_DETAIL)


func _on_back_button_pressed() -> void:
	SceneManager.change_scene(SceneManager.SCENES.MAIN_MENU)
