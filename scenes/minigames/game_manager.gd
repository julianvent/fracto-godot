extends Node

@export var countdown_scene: PackedScene
@export var identification_scene: PackedScene

@onready var current_scene = $CurrentScene
	
func _ready() -> void:
	_start_game()
	

func _start_game():
	var countdown = countdown_scene.instantiate()
	current_scene.add_child(countdown)
	countdown.connect("on_finish_countdown", Callable(self, "_load_game"))
	
	
func _load_game():
	var identification = identification_scene.instantiate()
	current_scene.add_child(identification)
	
