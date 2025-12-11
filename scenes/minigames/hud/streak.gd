extends PanelContainer

@onready var streak_label = $StreakSprite/Streak

@export var increase_animation_duration = 0.2

func update_streak(streak):
	var tween = create_tween()
	tween.tween_property(streak_label, "scale", Vector2(1.1, 1.1), increase_animation_duration)
	tween.tween_property(streak_label, "scale", Vector2(1, 1), increase_animation_duration)
	streak_label.text = str(streak)
