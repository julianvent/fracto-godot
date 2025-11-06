extends Control

var original_fraction := {"numerator": 1, "denominator": 2}
var reduced_fraction := {"numerator": 1, "denominator": 2}
	
func set_fraction(fraction):
	original_fraction.numerator = int(fraction.numerator)
	original_fraction.denominator = int(fraction.denominator)
	reduced_fraction = fraction.reduced
	update_display()


func update_display():
	$VBoxContainer/Numerator.text = str(original_fraction.numerator)
	$VBoxContainer/Denominator.text = str(original_fraction.denominator)


func _get_drag_data(at_position: Vector2):
	# DRAGGING PREVIEW
	var preview = duplicate()
	var c = Control.new()
	c.add_child(preview)
	preview.position = -0.5 * preview.size
	set_drag_preview(c)
	hide()
	
	# DATA
	var data = {
		"fraction": original_fraction,
		"reduced_fraction": reduced_fraction,
		"card_reference": self
	}
	
	return data


func _notification(what: int):
	if what == NOTIFICATION_DRAG_END:
		show()


func place_in_slot(slot_node: Node):
	if get_parent() != slot_node:
		get_parent().remove_child(self)
		slot_node.add_child(self)
		position = (slot_node.size - size) * 0.5
	
	mouse_filter = Control.MOUSE_FILTER_IGNORE
