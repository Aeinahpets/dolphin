extends Camera2D

@export var player : CharacterBody2D
@export var smoothing_enabled : bool
@export_range(1,10) var smoothing_distance : int = 5
@export var default_zoom:= 2.0
@export var zoom_speed := 2.0
@export var zoomed_out_zoom := 1.5 
var weight : float


func _ready():
	weight = float(11 - smoothing_distance) /100
	position = player.position
	
func _process(delta):
	_update_zoom(delta)
	_update_position()
	
func _update_zoom(delta):
	var zoom_factor = default_zoom
	if not player.is_in_water:
		zoom_factor = zoomed_out_zoom
	
	var target_zoom = Vector2.ONE * zoom_factor
	zoom = zoom.lerp(target_zoom, zoom_speed * delta)

func _update_position():
	var camera_position: Vector2
	if smoothing_enabled:
		camera_position = global_position.lerp(player.global_position, weight)
	else:
		camera_position = player.global_position
	
	global_position = camera_position.floor()
