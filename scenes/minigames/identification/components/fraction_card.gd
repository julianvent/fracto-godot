extends Control

@export var numerator: int = 1
@export var denominator: int = 2

func _ready():
	update_display()


func _get_drag_data(at_position: Vector2):
	var preview = duplicate()
	
	var c = Control.new()
	c.add_child(preview)
	preview.position = -0.5 * preview.size
	
	set_drag_preview(c)
	return self

func update_display():
	$VBoxContainer/Numerator.text = str(numerator)
	$VBoxContainer/Denominator.text = str(denominator)
