extends CharacterBody2D

# ==============================
# CONFIGURABLE VARIABLES
# ==============================
var input_active := true

@export var swim_speed: float = 300.0
@export var swim_acceleration: float = 10.0
@export var water_friction: float = 0.9
@export var air_gravity: float = 700.0
@export var jump_speed: float = 300.0
@export var min_jump_speed_threshold: float = 100.0
@export var max_dive_duration: float = 1.0

const DIVE_GRAVITY_FORCE := 3000.0
const BUOYANCY_FORCE := 200.0
const HORIZONTAL_SWIM_MULTIPLIER := 0.8

# ==============================
# STATES
# ==============================
enum State { SWIMMING, JUMPING, DIVING }
var current_state: State = State.SWIMMING
var is_in_water: bool = true

# ==============================
# INTERNAL VARIABLES
# ==============================
var direction: Vector2 = Vector2.ZERO
var dive_timer: float = 0.0
var dive_force: float = 0.0

# Flip & rotation
var is_flipping: bool = false
var flip_angle: float = 0.0
var flip_speed: float = 720.0

# ==============================
# NODE REFERENCES
# ==============================
@onready var water_detector: Area2D = $WaterDetector
@onready var sprite: AnimatedSprite2D = $spriteHolder/AnimatedSprite2D
@onready var sprite_holder: Node2D = $spriteHolder

# FX
var confetti_scene = preload("res://Objects/Ball/Confetti.tscn")

# ==============================
# LIFECYCLE
# ==============================
func _ready() -> void:
	pass

func _physics_process(delta: float) -> void:
	if input_active:
		_get_input(delta)

	match current_state:
		State.SWIMMING:
			_update_swimming(delta)
		State.JUMPING:
			_update_jumping(delta)
		State.DIVING:
			_update_dive(delta)

	move_and_slide()

# ==============================
# INPUT HANDLING
# ==============================
func _get_input(delta: float) -> void:
	direction = Input.get_vector("ui_left", "ui_right", "ui_up", "ui_down").normalized()

	_handle_rotation_and_flip(delta)

	if Input.is_action_just_pressed("dash"):
		_dash()

# ==============================
# ROTATION & FLIP
# ==============================
func _handle_rotation_and_flip(delta: float) -> void:
	if direction.length() > 0.1 and not is_in_water:
		var target_angle = direction.angle()
		_rotate_toward_angle(target_angle, delta)
		_update_sprite_flip(target_angle)
	elif velocity.length() > 0.1:
		var movement_angle = velocity.angle()
		_rotate_toward_angle(movement_angle, delta)
		_update_sprite_flip(movement_angle)

func _rotate_toward_angle(target_angle: float, delta: float) -> void:
	sprite_holder.rotation = lerp_angle(sprite_holder.rotation, target_angle, delta * 5.0)

func _update_sprite_flip(angle: float) -> void:
	if cos(angle) < 0:
		sprite.scale.y = -1
	else:
		sprite.scale.y = 1

# ==============================
# STATE UPDATES
# ==============================
func _update_swimming(delta: float) -> void:
	velocity = velocity.lerp(direction * swim_speed, swim_acceleration * delta)
	sprite.play("swim")

	if direction.length_squared() == 0:
		velocity *= water_friction

	if direction.y == 0 and velocity.y > 0:
		velocity.y -= BUOYANCY_FORCE * delta

func _update_jumping(delta: float) -> void:
	velocity.y += air_gravity * delta

func _update_dive(delta: float) -> void:
	dive_timer -= delta
	velocity.y += DIVE_GRAVITY_FORCE * delta

	if direction.y < 0:
		direction.y = 0

	var horizontal_input = Vector2(direction.x, 0)
	velocity = velocity.lerp(horizontal_input * swim_speed, swim_acceleration * delta)


	if dive_timer <= 0.0:
		current_state = State.SWIMMING

# ==============================
# STATE TRANSITIONS
# ==============================
func _set_in_water(value: bool) -> void:
	is_in_water = value

	if value:
		_on_enter_water()
	else:
		_on_exit_water()

func _on_enter_water() -> void:
	if current_state == State.JUMPING:
		if velocity.y > 0:
			_start_dive()
		else:
			current_state = State.SWIMMING

func _on_exit_water() -> void:
	if velocity.y < -min_jump_speed_threshold:
		_start_jump(false)
	else:
		_start_jump(true)

func _start_jump(fall_only) -> void:
	current_state = State.JUMPING
	if not fall_only:
		var exit_speed = velocity.length()
		var speed_factor = clamp(exit_speed / swim_speed, 0.5, 2.0)
		print("speed factor ", speed_factor)
		velocity.y = -jump_speed * speed_factor

func _start_dive() -> void:
	current_state = State.DIVING
	dive_force = clamp(velocity.y, swim_speed, swim_speed * 2)
	dive_timer = max_dive_duration * (clamp(velocity.y, 0, swim_speed * 2) / (swim_speed * 2))
	velocity.x *= HORIZONTAL_SWIM_MULTIPLIER

# ==============================
# SIGNAL HANDLERS
# ==============================

func _on_water_detector_area_entered(area: Area2D) -> void:
	if area.is_in_group("Water"):
		GameManager.is_in_water.emit(true)
		_set_in_water(true)
	if area.is_in_group("Spike"):
		GameManager.is_damaged.emit(20)

func _on_water_detector_area_exited(area: Area2D) -> void:
	if area.is_in_group("Water"):
		GameManager.is_in_water.emit(false)
		_set_in_water(false)

# ==============================
# INTERACTIONS
# ==============================
func _on_water_detector_body_entered(body: Node2D) -> void:
	if body.is_in_group("ball"):
		body.get_parent().hit_ball()
		body.apply_central_impulse(direction * 30)
		var confetti = confetti_scene.instantiate()
		confetti.global_position = body.global_position
		get_tree().root.add_child(confetti)
		confetti.emitting = true
		GameManager.hit_object.emit(self, body.get_parent().position)

# ==============================
# ACTIONS
# ==============================
func _dash() -> void:
	if is_in_water:
		velocity.x += direction.x * swim_speed * 5

func on_end_stage(win_stage) -> void:
	input_active = false
