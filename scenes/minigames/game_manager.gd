extends Node

@export var countdown_scene: PackedScene
@export var identification_scene: PackedScene

@onready var current_scene = $CurrentScene
@onready var HUD = $CurrentScene/HUD
@onready var timer = $TickTimer
@onready var time_left = Global.play_time

var points = 0
	
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
	
	var identification = identification_scene.instantiate()
	current_scene.add_child(identification)
	identification.connect("update_points", Callable(self, "_update_points"))
	
func _update_points(pointsGained):
	points += pointsGained
	


func _on_tick_timer_timeout() -> void:
	time_left -= 1
	HUD.update_timer(time_left)
