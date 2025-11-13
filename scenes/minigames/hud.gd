extends CanvasLayer

@onready var clock = $HBoxContainer/Clock
@onready var points = $HBoxContainer/VBoxContainer/Points

func _ready():
	clock.update_time(str(Global.play_time))

func update_timer(time_left):
	clock.update_time(time_left)
	
func update_points(p):
	points.update_points(p)
