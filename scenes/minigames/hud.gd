extends CanvasLayer

@onready var clock = $HBoxContainer/Clock
@onready var points = $HBoxContainer/Points
@onready var streak = $HBoxContainer/Streak

func _ready():
	clock.update_time(str(Global.play_time))

func update_timer(time_left):
	clock.update_time(time_left)
	
func update_points(p):
	points.update_points(p)
	
func add_points(p):
	points.add_points(p)
	
func update_streak(streak_count):
	streak.update_streak(streak_count)
