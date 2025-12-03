extends Node
# class_name StatsManager

const STATS_FILE_PATH := "user://stats.json"

var sessions: Array = []
var active_session_id: String = ""
var current_session: Dictionary = {}

var http_sync: HTTPRequest
var is_syncing: bool = false


func _ready() -> void:
	_load_sessions()

	# Crear el HTTPRequest en tiempo de ejecución
	http_sync = HTTPRequest.new()
	add_child(http_sync)
	http_sync.request_completed.connect(_on_sync_request_completed)


# 1) Cargar / guardar archivo local
func _load_sessions() -> void:
	if not FileAccess.file_exists(STATS_FILE_PATH):
		sessions = []
		return

	var file := FileAccess.open(STATS_FILE_PATH, FileAccess.READ)
	var text := file.get_as_text()
	file.close()

	var data = JSON.parse_string(text)
	if typeof(data) == TYPE_ARRAY:
		sessions = data
	else:
		sessions = []


func _save_sessions() -> void:
	var file := FileAccess.open(STATS_FILE_PATH, FileAccess.WRITE)
	file.store_string(JSON.stringify(sessions, "\t"))
	file.close()


# 2) Manejo de sesión activa
# Crear una nueva sesión a partir de la configuración actual (escuela, grupo, tiempo)
func create_session_from_config() -> void:
	ConfigManager.load_config()
	var cfg = ConfigManager.config

	var school = str(cfg.get_value(ConfigManager.SESSION_SECTION, "school", ""))
	var group  = str(cfg.get_value(ConfigManager.SESSION_SECTION, "group", ""))
	var minutes = str(cfg.get_value(ConfigManager.SESSION_SECTION, "minutes", "0")).to_int()
	var seconds = str(cfg.get_value(ConfigManager.SESSION_SECTION, "seconds", "0")).to_int()
	var duration_seconds = minutes * 60 + seconds

	var local_id = "sess_%d" % Time.get_unix_time_from_system()
	var datetime_str = Time.get_datetime_string_from_unix_time(Time.get_unix_time_from_system())
	var date_only = datetime_str.split("T")[0]  # "YYYY-MM-DD"

	var session := {
		"local_id": local_id,
		"remote_id": null,
		"user_id": Global.auth_user.get("id", 0),
		"school": school,
		"group": group,
		"duration_seconds": duration_seconds,
		"date": date_only,
		"players": [],      # jugadores: [{ alias, gender }]
		"juegos": {},       # para minijuegos, por si luego guardas porcentaje
		"synced": false     # false = pendiente de enviar a la API
	}

	sessions.append(session)
	active_session_id = local_id
	_save_sessions()


func has_active_session() -> bool:
	return not get_active_session().is_empty()


func set_active_session_by_local_id(local_id: String) -> void:
	active_session_id = local_id


func get_active_session() -> Dictionary:
	for s in sessions:
		if s.get("local_id", "") == active_session_id:
			return s
	return {}


# 3) Jugadores dentro de la sesión activa

func add_player_to_active_session(alias: String, gender: String) -> void:
	var session = get_active_session()
	if session.is_empty():
		return

	if alias.strip_edges() == "":
		alias = "Jugador %d" % (session["players"].size() + 1)

	var player := {
		"alias": alias,
		"gender": gender,
	}

	session["players"].append(player)
	session["synced"] = false

	for i in range(sessions.size()):
		if sessions[i].get("local_id", "") == session["local_id"]:
			sessions[i] = session
			break

	_save_sessions()


# 4) Helpers para pantallas de estadísticas

func get_all_sessions() -> Array:
	return sessions


func get_session_by_local_id(local_id: String) -> Dictionary:
	for s in sessions:
		if s.get("local_id", "") == local_id:
			return s
	return {}


func set_current_session(session: Dictionary) -> void:
	current_session = session


# Obtiene conteos básicos (total, M, F, N) para una sesión dada
func get_session_counts(session: Dictionary) -> Dictionary:
	var players: Array = session.get("players", [])
	var total := players.size()
	var masc := 0
	var fem := 0
	var nd := 0

	for p in players:
		match p.get("gender", ""):
			"M":
				masc += 1
			"F":
				fem += 1
			"N":
				nd += 1
			_:
				pass

	return {
		"total": total,
		"M": masc,
		"F": fem,
		"N": nd,
	}


# 5) CSV local (compatible con tu diseño anterior)

func export_session_to_csv(session: Dictionary) -> String:
	var rows: Array[String] = []

	var counts = get_session_counts(session)

	var folio = session.get("folio", session.get("remote_id", session.get("local_id", "")))
	var group = session.get("group", "")
	var school = session.get("school", "")
	var date = session.get("date", "")

	rows.append("Campo,Valor")
	rows.append("Folio,%s" % folio)
	rows.append("Grupo,%s" % group)
	rows.append("Escuela,%s" % school)
	rows.append("Fecha,%s" % date)

	rows.append("Total jugadores,%s" % counts["total"])
	rows.append("Masculinos,%s" % counts["M"])
	rows.append("Femeninas,%s" % counts["F"])
	rows.append("Prefiero no decirlo,%s" % counts["N"])

	var juegos: Dictionary = session.get("juegos", {})
	rows.append("Identificación de fracciones,%s" %
		str(juegos.get("identificacion_porcentaje", 0)) + "%")
	rows.append("Colorear fracciones,%s" %
		str(juegos.get("colorear_porcentaje", 0)) + "%")
	rows.append("Suma/resta de fracciones,%s" %
		str(juegos.get("suma_resta_porcentaje", 0)) + "%")

	var csv := "\n".join(rows)

	var dir_path := "user://exports"
	if not DirAccess.dir_exists_absolute(dir_path):
		DirAccess.make_dir_recursive_absolute(dir_path)

	var file_name := "sesion_%s.csv" % folio
	var full_path := dir_path + "/" + file_name

	var file := FileAccess.open(full_path, FileAccess.WRITE)
	file.store_string(csv)
	file.close()

	return full_path


# 6) Preparar sincronización con la API
# Construye el arreglo que espera Laravel en POST /sessions/sync
func build_pending_sessions_payload() -> Array:
	var pending: Array = []

	for s in sessions:
		if not s.get("synced", false):
			# Transformar jugadores locales -> formato API { alias, genero }
			var jugadores_payload: Array = []
			var players: Array = s.get("players", [])

			for p in players:
				jugadores_payload.append({
					"alias": p.get("alias", ""),
					"genero": p.get("gender", ""),  # la API espera "genero"
				})

			pending.append({
				"local_id": s.get("local_id", ""),
				"escuela": s.get("school", ""),
				"grupo": s.get("group", ""),
				"duracion_segundos": s.get("duration_seconds", 0),
				"fecha": s.get("date", ""),
				"jugadores": jugadores_payload,
			})

	return pending


# Marca como sincronizadas las sesiones que la API devolvió
func mark_sessions_as_synced(mapping: Dictionary) -> void:
	for i in range(sessions.size()):
		var s = sessions[i]
		var local_id = s.get("local_id", "")
		if mapping.has(local_id):
			s["remote_id"] = mapping[local_id]
			s["synced"] = true
			sessions[i] = s

	_save_sessions()

func has_pending_sessions() -> bool:
	for s in sessions:
		if not s.get("synced", false):
			return true
	return false

# 7) Llamar a la API: POST /v1/auth/sessions/sync
func sync_pending_sessions() -> void:
	if is_syncing:
		return

	var payload_sessions := build_pending_sessions_payload()
	if payload_sessions.is_empty():
		print("No hay sesiones pendientes por sincronizar.")
		return

	if Global.auth_token == "":
		print("No hay token de autenticación, no se puede sincronizar.")
		return

	# Usa la misma base que ya usas para login, por ejemplo:
	# Global.API_BASE_URL = "https://tu-dominio.com/api"
	var url: String = Global.API_BASE_URL + "/v1/auth/sessions/sync"


	var headers := [
		"Content-Type: application/json",
		"Accept: application/json",
		"Authorization: " + "Bearer " + Global.auth_token,
	]

	var body_dict := {"sessions": payload_sessions}
	var body_json := JSON.stringify(body_dict)

	var err := http_sync.request(url, headers, HTTPClient.METHOD_POST, body_json)
	if err != OK:
		push_error("Error al iniciar request de sync: %s" % err)
	else:
		is_syncing = true


func _on_sync_request_completed(result: int, response_code: int, headers: PackedStringArray, body: PackedByteArray) -> void:
	is_syncing = false

	if result != HTTPRequest.RESULT_SUCCESS:
		print("Error de red al sincronizar sesiones:", result)
		return

	var text := body.get_string_from_utf8()
	var data = JSON.parse_string(text)
	if typeof(data) != TYPE_DICTIONARY:
		print("Respuesta inesperada de sync:", text)
		return

	if response_code != 200:
		print("Error HTTP en sync:", response_code, text)
		return

	var mapping: Dictionary = data.get("mapping", {})
	mark_sessions_as_synced(mapping)
	print("Sesiones sincronizadas OK:", mapping)
