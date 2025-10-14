extends CanvasLayer

func _ready():
	update_timer()

func update_timer():
	$label.text = str(Global.seconds_left)
	Global.seconds_left -= 1
