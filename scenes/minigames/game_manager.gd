extends Node

@export var countdown_scene: PackedScene
@export var identification_scene: PackedScene
@export var continue_scene: PackedScene
@export var identification_replay = 3

@onready var current_scene = $CurrentScene
@onready var HUD = $HUD
@onready var timer = $TickTimer

# Game states
enum GameState { IDLE, COUNTDOWN, PLAYING, REPLAYING, CONTINUE, FINISHED }
var state: int = GameState.IDLE

# Game variables
var time_left: int
var times_replayed: int = 0
var current_game = 0
var points = 0
var streak = 0

var games := []
	
func _ready() -> void:
	games = [
		{"scene": identification_scene, "replays": identification_replay},
		{"scene": identification_scene, "replays": identification_replay},
	]
	time_left = Global.play_time
	_reset_for_new_run()
	_start_game()

# --- utils ---
func _reset_for_new_run():
	time_left = Global.play_time
	points = 0
	times_replayed = 0
	current_game = 0
	HUD.update_points(points)
	HUD.update_timer(time_left)
	

func _clear_current_scene_children():
	for child in current_scene.get_children():
		child.queue_free()
	await get_tree().process_frame



# --- game flow ---
func _start_game():
	state = GameState.COUNTDOWN
	HUD.hide()
	_clear_current_scene_children()
	var countdown = countdown_scene.instantiate()
	current_scene.add_child(countdown)
	countdown.connect("on_finish_countdown", Callable(self, "_on_countdown_finished"), CONNECT_ONE_SHOT)


func _on_countdown_finished():
	_load_game()


func _load_game():
	state = GameState.PLAYING
	HUD.show()
	timer.start()
	_reset_timer_and_hud()
	
	var game_def = games[current_game]
	var game_scene = game_def.scene.instantiate()
	current_scene.add_child(game_scene)
	game_scene.connect("game_finished", Callable(self,"_on_game_finished"), CONNECT_ONE_SHOT)
	game_scene.connect("update_points", Callable(self, "_update_points"))
	game_scene.connect("update_streak", Callable(self, "_update_streak"))
	

func _reset_timer_and_hud() -> void:
	timer.start()
	HUD.update_timer(time_left)
	HUD.update_points(points)

	
func _update_points(points_gained):
	points += points_gained
	HUD.update_points(points)
	HUD.add_points(points_gained)
	
	
func _update_streak(reset):
	if reset:
		streak = 0
	else:
		streak += 1
	HUD.update_streak(streak)


func _on_tick_timer_timeout() -> void:
	time_left -= 1
	HUD.update_timer(time_left)
	
	if time_left <= 0:
		await get_tree().create_timer(1).timeout
		_on_game_finished()
		

func _on_game_finished():
	timer.stop()
	if time_left <= 0:
		_on_all_games_finished()
		return
		
	await get_tree().create_timer(1).timeout
	state = GameState.REPLAYING
	
	_clear_current_scene_children()
	
	times_replayed += 1
	var max_replays = games[current_game].replays
	if times_replayed < max_replays:
		_load_game()
	else:
		times_replayed = 0
		current_game += 1
		if current_game >= games.size():
			_on_all_games_finished()
		else:
			_show_continue()


func _on_all_games_finished():
	state = GameState.FINISHED
	_show_stats()


func _show_continue():
	state = GameState.CONTINUE
	HUD.hide()
	_clear_current_scene_children()
	var continue_sc = continue_scene.instantiate()
	current_scene.add_child(continue_sc)
	continue_sc.connect("on_continue", Callable(self, "_on_continue"), CONNECT_ONE_SHOT)


func _on_continue():
	_start_game()
	
	
func _show_stats():
	SceneManager.change_scene(SceneManager.SCENES.PLAYER_CONFIG)
