extends Node2D

@onready var hoop = preload("res://Objects/hoop.tscn")

func spawn_hoops():
	var new_hoop = hoop.instantiate()
	add_child(new_hoop)
	new_hoop.position(246.0, 190)


func _on_hoop_timer_timeout() -> void:
	spawn_hoops()
