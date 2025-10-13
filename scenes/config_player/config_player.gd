extends Control

@export var group: ButtonGroup
var gender

func _ready():
	for button in group.get_buttons():
		button.pressed.connect(Callable(_on_gender_pressed).bind(button.text))


func _on_back_pressed():
	SceneManager.change_scene(SceneManager.MENUS.SESSION_MENU)

	
func _on_gender_pressed(_gender: String):
	gender = _gender


func _on_play_pressed():
	if not gender:
		$ErrorLabel.visible = true
		return
	$ErrorLabel.visible = false
