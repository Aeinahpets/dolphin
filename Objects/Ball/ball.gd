extends Node2D
@onready var ball: RigidBody2D = $Ball
@onready var ceiling: StaticBody2D = $Ceiling

func _process(delta: float) -> void:
	queue_redraw()

func _draw() -> void:
	draw_line(ceiling.position, ball.position, Color.RED)

func hit_ball():
	await get_tree().create_timer(1).timeout
	queue_free()
