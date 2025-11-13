extends Node

@export var countdown_scene: PackedScene
@export var identification_scene: PackedScene
@export var identification_replay = 3

@onready var current_scene = $CurrentScene
@onready var HUD = $HUD
@onready var timer = $TickTimer
@onready var time_left = Global.play_time

@onready var times_replayed = 0
@onready var current_game = 0
var points = 0

@onready var games = [
	{"scene": identification_scene, "replays": identification_replay},
]
	
func _ready() -> void:
	_start_game()
	

func _start_game():
	HUD.hide()
	var countdown = countdown_scene.instantiate()
	current_scene.add_child(countdown)
	countdown.connect("on_finish_countdown", Callable(self, "_load_game"))
	
	
func _load_game():
	HUD.show()
	timer.start()
	
	var game_scene = games[current_game].scene.instantiate()
	current_scene.add_child(game_scene)
	game_scene.connect("update_points", Callable(self, "_update_points"))
	game_scene.connect("game_finished", Callable(self,"_replay_game"))
	
func _update_points(pointsGained):
	points += pointsGained
	HUD.update_points(points)

func _on_tick_timer_timeout() -> void:
	time_left -= 1
	HUD.update_timer(time_left)

func _replay_game():
	var current_game_replays = games[current_game].replays
	for child in current_scene.get_children():
		child.queue_free()
	
	times_replayed += 1
	if times_replayed < current_game_replays:
		_load_game()
	else:
		times_replayed = 0
		#current_game += 1
		_start_game()
