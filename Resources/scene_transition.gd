extends Node

@onready var animation_player = find_child('AnimationPlayer')
var scene_target
var user_prefs: UserPreferences

func change_scene(target: String) ->void:
	scene_target = target
	animation_player.play("transition")
	
func _on_animation_player_animation_finished(anim_name: StringName) -> void:
	if anim_name == "transition":
#		user_prefs.current_scene = anim_name
		get_tree().change_scene_to_file(scene_target)
