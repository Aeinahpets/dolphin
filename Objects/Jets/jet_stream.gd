extends Area2D

# Direction and strength of push
@export var push_direction: Vector2 = Vector2.RIGHT
@export var push_force: float = 200.0

# Store bodies currently inside
var bodies_in_stream: Array = []

func _physics_process(delta):
	for body in bodies_in_stream:
		body.velocity += push_direction.normalized() * push_force 



func _on_area_entered(area: Area2D) -> void:
	print("area enter")
	if area.is_in_group("player"):
		print("area")
		bodies_in_stream.append(area.get_parent())


func _on_area_exited(area: Area2D) -> void:
	if area.is_in_group("player"):
		bodies_in_stream.erase(area.get_parent())
