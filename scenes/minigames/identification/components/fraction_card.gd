extends Control

@export var numerator: int = 1
@export var denominator: int = 2

var original_fraction := {"numerator": 1, "denominator": 2}
var reduced_fraction := {"numerator": 1, "denominator": 2}

var preview = null
var original_position = Vector2.ZERO
	
func set_fraction(fraction):
	original_fraction.numerator = int(fraction.numerator)
	original_fraction.denominator = int(fraction.denominator)
	
	reduced_fraction = fraction.reduced
	update_display()


func _get_drag_data(at_position: Vector2):
	preview = duplicate()
	original_position = global_position
	
	var c = Control.new()
	c.add_child(preview)
	preview.position = -0.5 * preview.size
	
	set_drag_preview(c)
	return self

func _notification(what: int):
	if what == NOTIFICATION_DRAG_END:
		print(to_string())
		print(get_parent())

func update_display():
	$VBoxContainer/Numerator.text = str(original_fraction.numerator)
	$VBoxContainer/Denominator.text = str(original_fraction.denominator)
	
func return_to_original():
	print(preview.global_position)
	print(original_position)
	get_tree().get_root().add_child(preview)
	preview.create_tween().tween_property(preview, "position", original_position, 0.3).set_ease(Tween.EASE_OUT)
