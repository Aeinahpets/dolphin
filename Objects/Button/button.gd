extends Area2D

@export var target: Door
var is_active := true

func _on_area_entered(area: Area2D) -> void:
	if is_active and area.is_in_group("player"):
		is_active = false
		target.queue_free()
