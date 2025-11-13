extends Control
class_name FractionPizza

@export var stroke_color: Color
@export var crust_color: Color
@export var base_color: Color = Color.SADDLE_BROWN
@export var fill_color: Color
@export var stroke_width: float = 2.0
@export var pizza_size: Vector2 = Vector2(250.0, 250.0)

var original_fraction := {"numerator": 1, "denominator": 8}
var reduced_fraction := {"numerator": 1, "denominator": 8}

func set_fraction(fraction: Dictionary):
	original_fraction.numerator = int(fraction.numerator)
	original_fraction.denominator = int(fraction.denominator)
	reduced_fraction = fraction.reduced

func _draw():
	_draw_pizza()

func _draw_pizza():
	size = pizza_size
	var center = size * 0.5
	var radius = min(size.x, size.y) * 0.45
	
	var two_pi = TAU
	draw_circle(center, radius, base_color)
	
	var rng = RandomNumberGenerator.new()
	var chosen_fraction = rng.randi_range(0, 1)
	
	var d = int(original_fraction.denominator)
	var n = int(original_fraction.numerator)
	
	if chosen_fraction:
		d = int(reduced_fraction.denominator)
		n = int(reduced_fraction.numerator)
		
	for i in range(original_fraction.denominator):
		
		var a0 = -PI * 0.5 + two_pi * (i / float(d))
		var a1 = -PI * 0.5 + two_pi * ((i + 1) / float(d))
		var angle_span = a1 - a0
		
		# choose segments to approximate the arc (higher -> smoother)
		var segs = max(4, int(ceil(8.0 * angle_span / (TAU) * d)))
		
		var points: Array = []
		points.append(center)
		for s in range(segs + 1):
			var t = s / float(segs)
			var a = a0 + angle_span * t
			points.append(center + Vector2(cos(a), sin(a)) * radius)
		
		if i < n:
			draw_colored_polygon(points, fill_color)

	for i in range(d):
		var a = -PI * 0.5 + two_pi * (i / float(d))
		var p = center + Vector2(cos(a), sin(a)) * radius
		draw_line(center, p, stroke_color, stroke_width)
		
	var circle_segs = max(32, d * 8)
	var circle_points: Array = []
	for s in range(circle_segs):
		var a = -PI * 0.5 + two_pi * (s / float(circle_segs))
		circle_points.append(center + Vector2(cos(a), sin(a)) * radius)
		
	circle_points.append(circle_points[0])
	draw_polyline(circle_points, crust_color , stroke_width * 4)
