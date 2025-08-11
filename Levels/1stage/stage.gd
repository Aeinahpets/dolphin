extends Node2D

@onready var hoop = preload("res://Objects/hoop/hoop.tscn")
@onready var ball = preload("res://Objects/Ball/Ball.tscn")
@onready var spawner: Node2D = $Spawner

var available_spawn_points: Array = []
var taken_spawn_points: Array = []
var spawn_ball := true

func _ready() -> void:
	GameManager.hit_object.connect(object_hit)
	for marker in spawner.get_children():
		if marker is Marker2D:
			available_spawn_points.append(marker.global_position)

func spawn_objects():
	var new_obj 
	if spawn_ball:
		spawn_ball = false
		new_obj = ball.instantiate()
	else:
		spawn_ball= true
		new_obj = hoop.instantiate()
	add_child(new_obj)
	var point = available_spawn_points.pick_random()
	available_spawn_points.erase(point)
	taken_spawn_points.append(point)
	new_obj.position = point


func _on_hoop_timer_timeout() -> void:
	if !available_spawn_points.is_empty():
		spawn_objects()

func object_hit(object, point):
	available_spawn_points.append(point)
	taken_spawn_points.erase(point)
