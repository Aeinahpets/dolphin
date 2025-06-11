extends CharacterBody2D

# --- Exported Variables (Tweak in Inspector) ---
@export var swim_speed: float = 200.0
@export var swim_acceleration: float = 10.0
@export var water_friction: float = 0.9 # How much speed is retained in water
@export var air_gravity: float = 800.0
@export var jump_speed: float = 400.0 # Initial upward speed when jumping
@export var min_jump_speed_threshold: float = 150.0 # Min vertical speed to initiate a jump

# --- Internal Variables ---
var current_state: String = "SWIMMING"
var is_in_water: bool = true # Assume starting in water
var direction: Vector2 = Vector2.ZERO # Stores input direction

# --- Node References (Assign in _ready or by drag-and-drop) ---
@onready var water_detector: Area2D = $WaterDetector # Assuming you have this node

func _physics_process(delta: float):
	_get_input()

	match current_state:
		"SWIMMING":
			_handle_swimming(delta)
		"JUMPING":
			_handle_jumping(delta)

	move_and_slide() # Godot's built-in movement function

func _get_input():
	direction = Input.get_vector("ui_left", "ui_right", "ui_up", "ui_down")

func _handle_swimming(delta: float):
	print("swimming")
	if is_in_water:
		# Apply input direction with acceleration
		velocity = velocity.lerp(direction * swim_speed, swim_acceleration * delta)
		# Apply some friction to slow down when not actively moving
		if direction.length_squared() == 0:
			velocity *= water_friction
	else:
		# If somehow out of water in SWIMMING state (shouldn't happen often if logic is robust)
		# Transition to JUMPING if conditions met, otherwise fall
		_try_jump_or_fall()

func _handle_jumping(delta: float):
	print("jumping")
	# Apply gravity
	velocity.y += air_gravity * delta

	# Check for re-entry into water
	if is_in_water:
		# If velocity is mostly downward, we've fallen back into the water
		if velocity.y > 0: # Only transition if falling back down
			current_state = "SWIMMING"
			# Optional: Reduce horizontal speed slightly on water re-entry
			velocity.x *= water_friction # Slow down horizontal movement slightly
			velocity.y = 0 # Reset vertical velocity on water entry

func _try_jump_or_fall():
	# Condition to initiate a jump:
	# 1. Dolphin is *leaving* the water
	# 2. Has sufficient upward vertical speed (from a quick swim up)
	if !is_in_water and velocity.y < -min_jump_speed_threshold: # Negative Y is upwards
		current_state = "JUMPING"
		# Apply an initial jump boost if desired, or just use current upward speed
		velocity.y = min(velocity.y, -jump_speed) # Ensure minimum jump speed
	elif !is_in_water and velocity.y >= -min_jump_speed_threshold:
		# If not enough speed to jump, just start falling
		current_state = "JUMPING" # Or "FALLING" state if you want more granularity
		# Don't apply jump_speed, just let gravity take over


func _on_water_detector_area_entered(area: Area2D) -> void:
	print("enter area")
	is_in_water = true
	# If entering water while jumping, transition back to swimming
	if current_state == "JUMPING":
		current_state = "SWIMMING"
		velocity.y = 0 # Stop vertical momentum


func _on_water_detector_area_exited(area: Area2D) -> void:
	print("exit area")
	is_in_water = false
	# When leaving water, check if a jump should be initiated
	_try_jump_or_fall()
