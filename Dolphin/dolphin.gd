extends CharacterBody2D

var input_active:= true

# --- Exported Variables (Tweak in Inspector) ---
@export var swim_speed: float =300.0
@export var swim_acceleration: float = 20.0
@export var water_friction: float = 0.9 # How much speed is retained in water
@export var air_gravity: float = 700.0
@export var jump_speed: float = 250.0 # Initial upward speed when jumping
@export var min_jump_speed_threshold: float = 150.0 # Min vertical speed to initiate a jump
enum State { SWIMMING, JUMPING, DIVING }

# --- Internal Variables ---
var current_state: State = State.SWIMMING
var is_in_water: bool = true # Assume starting in water
var direction: Vector2 = Vector2.ZERO 

const DIVE_GRAVITY_FORCE := 3000.0
const BUOYANCY_FORCE := 200.0
const HORIZONTAL_SWIM_MULTIPLIER := 0.8

@export var max_dive_duration: float = 1.0
var dive_timer: float = 0.0
var dive_force: float = 0.0
var is_flipping: bool = false
var flip_angle: float = 0.0
var flip_speed: float = 720.0

# --- Node References (Assign in _ready or by drag-and-drop) ---
@onready var water_detector: Area2D = $WaterDetector # Assuming you have this node
@onready var sprite: AnimatedSprite2D = $spriteHolder/AnimatedSprite2D
@onready var sprite_holder: Node2D = $spriteHolder

var confetti_scene = preload("res://Objects/Ball/Confetti.tscn")

func _ready() -> void:
	#GameManager.end_stage.connect(on_end_stage)
	pass
	
func _physics_process(delta: float):
	if input_active:
		_get_input(delta)
		match current_state:
			State.SWIMMING:
				_handle_swimming(delta)
			State.JUMPING:
				_handle_jumping(delta)
			State.DIVING:
				_handle_dive(delta)

		move_and_slide()
			
func _get_input(delta):
	# Get input direction
	direction = Input.get_vector("ui_left", "ui_right", "ui_up", "ui_down").normalized()

	if direction.length() > 0.1 and not is_in_water:
		# If there's input, face input direction
		var target_angle = direction.angle()
		_rotate_toward_angle(target_angle, delta)
		
		_update_sprite_flip(target_angle)
	else:
		# If no input, face the direction of movement (velocity)
		if velocity.length() > 0.1:  # Only rotate if moving
			var movement_angle = velocity.angle()
			_rotate_toward_angle(movement_angle, delta)
			_update_sprite_flip(movement_angle)

func _rotate_toward_angle(target_angle, delta):
	# Smoothly rotate toward target_angle
	sprite_holder.rotation = lerp_angle(sprite_holder.rotation, target_angle, delta * 5.0)

func _update_sprite_flip(angle):
	# Flip sprite based on angle (assuming right is 0 rad)
	if cos(angle) < 0:  # Moving left (angle in left half)
		sprite.scale.y = -1
	else:
		sprite.scale.y = 1
		
func _handle_swimming(delta: float):
	velocity = velocity.lerp(direction * swim_speed, swim_acceleration * delta)
	sprite.play("swim")
	# Water friction
	if direction.length_squared() == 0:
		velocity *= water_friction

	# Add slight buoyancy when not actively swimming down
	if direction.y == 0 and velocity.y > 0:
			velocity.y -= BUOYANCY_FORCE * delta  # Simulate upward push from water


func _handle_jumping(delta: float):
	# Apply gravity
	velocity.y += air_gravity * delta

	if is_in_water:
		if velocity.y > 0:
			current_state = State.SWIMMING
			velocity.x *= water_friction
			velocity.y *= 0.5 

func _try_jump_or_fall():
	if !is_in_water and velocity.y < -min_jump_speed_threshold: 
		current_state = State.JUMPING
		velocity.y = min(velocity.y, -jump_speed) 
	elif !is_in_water and velocity.y >= -min_jump_speed_threshold:
		current_state = State.JUMPING

func _on_water_detector_area_entered(area: Area2D) -> void:
	if area.is_in_group("Water"):
		GameManager.is_in_water.emit(true)
		is_in_water = true
		if current_state == State.JUMPING and velocity.y > 0:
			current_state = State.DIVING
			dive_force = clamp(velocity.y, swim_speed, swim_speed*2) # Or based on jump height
			dive_timer = max_dive_duration * (clamp(velocity.y, 0, swim_speed * 2) / (swim_speed * 2))
			velocity.x *= HORIZONTAL_SWIM_MULTIPLIER
	if area.is_in_group("Spike"):
		GameManager.is_damaged.emit(20)
		

func _on_water_detector_area_exited(area: Area2D) -> void:
	if area.is_in_group("Water"):
		GameManager.is_in_water.emit(false)
		is_in_water = false
		_try_jump_or_fall()

func _handle_dive(delta: float):
	dive_timer -= delta	
	velocity.y += DIVE_GRAVITY_FORCE * delta
	
	# Prevent upward motion during dive
	if direction.y < 0:
		direction.y = 0

	# Allow horizontal swimming but reduced
	var horizontal_input = Vector2(direction.x, 0)
	velocity = velocity.lerp(horizontal_input * swim_speed, swim_acceleration * delta)

	if dive_timer <= 0.0:
		current_state = State.SWIMMING

func _on_water_detector_body_entered(body: Node2D) -> void:
	if body.is_in_group("ball"):
		body.get_parent().hit_ball()
		body.apply_central_impulse(direction * 30)
		var confetti = confetti_scene.instantiate()
		confetti.global_position = body.global_position
		get_tree().root.add_child(confetti)
		confetti.emitting = true
		GameManager.hit_object.emit(self, position)

func on_end_stage(win_stage):
	input_active = false
