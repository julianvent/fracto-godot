extends Node

@onready var points = $VBoxContainer/Points

func update_points(p):
	points.text = str(p)
