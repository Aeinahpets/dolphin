extends CanvasLayer
@onready var label: Label = $Label

func _ready() -> void:
	GameManager.end_stage.connect(on_end_stage)
	
func on_end_stage(win_stage):
	visible = true
	if win_stage:
		label.text = "Congrats you performed like a pro!!!"
	else:
		label.text = "The audience didnt like your performence :("


func _on_button_pressed() -> void:
	SceneTransition.change_scene("res://Levels/1stage/Enclosure.tscn")
