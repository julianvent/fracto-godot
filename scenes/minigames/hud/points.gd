extends Node

@onready var points = $VBoxContainer/Points
@export var floating_points_scene: PackedScene
@export var increase_animation_duration = 0.2
@export var floating_points_distance = 5.0


func update_points(total_points):
	points.text = str(total_points)
	
func add_points(points_gained):
	_show_points(points_gained)

func _show_points(p) -> void:
	var floating_points = floating_points_scene.instantiate()
	add_child(floating_points)
	floating_points.play(p, self.position, floating_points_distance)
