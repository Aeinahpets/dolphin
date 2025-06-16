extends CanvasLayer



func _on_new_game_pressed() -> void:
	get_tree().change_scene_to_file("res://Levels/1stage/Tank.tscn")


func _on_quit_pressed() -> void:
	get_tree().quit()


func _on_ocean_pressed() -> void:
	get_tree().change_scene_to_file("res://Levels/Main.tscn")
