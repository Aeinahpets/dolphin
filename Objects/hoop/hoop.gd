extends Node2D


func _on_area_2d_area_entered(area: Area2D) -> void:
	if area.is_in_group("player"):
		GameManager.hit_object.emit(self, position)
		$AnimationPlayer.play("grab")

func _on_animation_player_animation_finished(anim_name: StringName) -> void:
	if anim_name == "grab":
		queue_free()
