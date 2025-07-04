extends CanvasLayer

@onready var animation_player = find_child('AnimationPlayer')
var scene_target

func change_scene(target: String) ->void:
	scene_target = target
	print("change")
	animation_player.play("transition")
	await animation_player.animation_finished
	
func _on_animation_player_animation_finished(anim_name: StringName) -> void:
	if anim_name == "transition":
		get_tree().change_scene_to_file(scene_target)
