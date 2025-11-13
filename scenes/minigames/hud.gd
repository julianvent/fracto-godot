extends CanvasLayer

func _ready():
	$Time.text = str(Global.play_time)

func update_timer(time_left):
	$Time.text = str(time_left)
	
func update_points(points):
	$Points.text = str(points)
