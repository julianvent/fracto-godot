extends CanvasLayer

func _ready():
	update_timer()

func update_timer():
	$Time.text = str(Global.play_time)
	Global.play_time -= 1
