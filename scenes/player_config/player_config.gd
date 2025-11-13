extends Control

@export var group: ButtonGroup
var gender: String
var alias: String = ""

func _ready():
	for button in group.get_buttons():
		button.pressed.connect(Callable(_on_gender_pressed).bind(button.text))


func _on_back_pressed():
	SceneManager.change_scene(SceneManager.SCENES.SESSION_MENU)

	
func _on_gender_pressed(_gender: String):
	gender = _gender


func _on_play_pressed():
	if not gender:
		$GenderError.visible = true
		return
	Global.player_gender = gender
	$GenderError.visible = false
	
	alias = $Alias.text
	Global.player_name = alias
	
	SceneManager.change_scene(SceneManager.SCENES.GAME_MANAGER)
