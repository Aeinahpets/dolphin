extends CharacterBody2D

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

var confetti_scene = preload("res://Objects/Confetti.tscn")

func _physics_process(delta: float):
	_get_input(delta)

	match current_state:
		State.SWIMMING:
			_handle_swimming(delta)
		State.JUMPING:
			_handle_jumping(delta)
		State.DIVING:
			_handle_dive(delta)

	if is_flipping:
		var rotation_step = flip_speed * delta
		sprite_holder.rotation += deg_to_rad(rotation_step)
		flip_angle += rotation_step

		if flip_angle >= 360.0:
			is_flipping = false
			sprite_holder.rotation = 0.0 # Reset rotation to upright
			
	move_and_slide()
	
	apply_hit_force()

func _get_input(delta):
	direction = Input.get_vector("ui_left", "ui_right", "ui_up", "ui_down")

	if velocity.length() > 10:
		var target_angle = velocity.angle()
		sprite_holder.rotation = lerp_angle(sprite_holder.rotation, target_angle, delta * 5.0)
		if abs(target_angle) > PI / 2:
			sprite.scale.y = -1 
		else:
			sprite.scale.y = 1 
			
func _handle_swimming(delta: float):
	if is_in_water:
		# Apply input direction with acceleration
		velocity = velocity.lerp(direction * swim_speed, swim_acceleration * delta)
		sprite.play("swim")
		# Water friction
		if direction.length_squared() == 0:
			velocity *= water_friction

		# Add slight buoyancy when not actively swimming down
		if direction.y == 0 and velocity.y > 0:
			velocity.y -= 200 * delta  # Simulate upward push from water
	else:
		# If somehow out of water in SWIMMING state (shouldn't happen often if logic is robust)
		# Transition to JUMPING if conditions met, otherwise fall
		_try_jump_or_fall()

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
			dive_timer = max_dive_duration * (dive_force / (swim_speed*2))
			velocity.x *= 0.8

func _on_water_detector_area_exited(area: Area2D) -> void:
	if area.is_in_group("Water"):
		GameManager.is_in_water.emit(false)
		is_in_water = false
		_try_jump_or_fall()

func _handle_dive(delta: float):
	dive_timer -= delta	
	velocity.y += 3000 * delta
	
	# Prevent upward motion during dive
	if direction.y < 0:
		direction.y = 0

	# Allow horizontal swimming but reduced
	var horizontal_input = Vector2(direction.x, 0)
	velocity = velocity.lerp(horizontal_input * swim_speed, swim_acceleration * delta)

	if dive_timer <= 0.0:
		current_state = State.SWIMMING

func _input(event: InputEvent) -> void:
	if event.is_action_pressed("flip"):
		do_flip()
		
func do_flip():
	if current_state == State.JUMPING :
		is_flipping = true
		flip_angle = 0.0
		
		var rotation_step = 1
		sprite_holder.rotation += deg_to_rad(rotation_step)
		flip_angle += rotation_step

		if flip_angle >= 360.0:
			is_flipping = false
			sprite_holder.rotation = 0.0

func apply_hit_force():
	for i in get_slide_collision_count():
		
		var collision = get_slide_collision(i)
		var collider = collision.get_collider()
		if collider is RigidBody2D:
			# Apply impulse to ball based on movement direction
			var ball := collider as RigidBody2D
			ball.apply_central_impulse(direction * 30)
			var confetti = confetti_scene.instantiate()
			confetti.global_position = collision.get_position()
			get_tree().current_scene.add_child(confetti)
			confetti.emitting = true
