extends Node

@onready var time = $VBoxContainer/PanelContainer/Time

func update_time(time_left):
	time.text = str(time_left)
