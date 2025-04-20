#structure
#player
#	collision_detection
#	standing_collision
#	crouching_collision
#	neck
#		head
#     eyes
#			Camera3D

extends CharacterBody3D

# Player Nodes
@onready var head: Node3D = $neck/head
@onready var neck: Node3D = $neck
@onready var eyes: Node3D = $neck/head/eyes
@onready var standing_collision_shape: CollisionShape3D = $standing_collision_shape
@onready var crouching_collision_shape: CollisionShape3D = $crouching_collision_shape
@onready var collision_detection: RayCast3D = $collision_detection
@onready var camera_3d: Camera3D = $neck/head/eyes/Camera3D
@onready var animation_player: AnimationPlayer = $neck/head/eyes/AnimationPlayer

# Speed Vars
var current_speed : float = 5.0
const WALK_SPEED : float = 5.0
const SPRINT_SPEED : float = 8.0
const CROUCH_SPEED : float = 3.0

# States
var walking : bool = false
var sprinting : bool = false
var crouching : bool = false
var free_looking : bool = false
var sliding : bool = false
var looking_back : bool = false

# Slide Vars
var slide_timer : float = 0.0
var slide_timer_max : float = 1.3 # in seconds
var slide_vector = Vector2.ZERO
const SLIDE_SPEED :float = 10.0

# headbob
const HEAD_BOBBING_SPRINT_SPEED : float = 22.0
const HEAD_BOBBING_WALK_SPEED : float = 14.0
const HEAD_BOBBING_CROUCH_SPEED : float = 10.0

const HEAD_BOBBING_SPRINT_INTENSITY : float = 0.2
const HEAD_BOBBING_WALK_INTENSITY : float = 0.1
const HEAD_BOBBING_CROUCH_INTENSITY : float = 0.05

var head_bobbing_current_intensity : float = 0.0
var head_bobbing_vector = Vector2.ZERO
var head_bobbing_index : float = 0.0

# Movement Vars
var crouching_depth :float = -0.5
const JUMP_VELOCITY :float = 4.5
var lerp_speed : float = 10.0
var air_lerp_speed : float = 3.0
var free_look_tilt_amount : float = 6
var last_velocity = Vector3.ZERO
#Input VarINERTIA 
var direction : Vector3
const MOUSE_SENSITIVITY = 0.1

func _ready() -> void:
	Input.mouse_mode = Input.MOUSE_MODE_CAPTURED
	
func _input(event: InputEvent) -> void:
	if Input.is_action_just_pressed("quit"):
		get_tree().quit()
		
	if event is InputEventMouseMotion:
		if free_looking:
			neck.rotate_y(deg_to_rad(-event.relative.x * MOUSE_SENSITIVITY))
			neck.rotation.y = clamp(neck.rotation.y, deg_to_rad(-160), deg_to_rad(160))
			
		else:
			rotate_y(deg_to_rad(-event.relative.x * MOUSE_SENSITIVITY))
		head.rotate_x(deg_to_rad(-event.relative.y * MOUSE_SENSITIVITY))
		head.rotation.x = clamp(head.rotation.x, deg_to_rad(-60), deg_to_rad(80))

func _physics_process(delta: float) -> void:
	# Getting movement input
	var input_dir := Input.get_vector("left", "right", "forward", "backward")
	
	# Handling Movement State
	
	# Crouching
	if Input.is_action_pressed("crouch"):
		current_speed = lerp(current_speed, CROUCH_SPEED, delta * lerp_speed)
		head.position.y = lerp(head.position.y, crouching_depth, delta * lerp_speed)
		
		standing_collision_shape.disabled = true
		crouching_collision_shape.disabled = false
		
		if sprinting and input_dir != Vector2.ZERO:
			sliding = true
			slide_timer = slide_timer_max
			slide_vector = input_dir
			free_looking = true
		
		walking = false
		sprinting = false
		crouching = true
		
	elif !collision_detection.is_colliding():
		# Standing
		standing_collision_shape.disabled = false 
		crouching_collision_shape.disabled = true 
		head.position.y = lerp(head.position.y, 0.0, delta * lerp_speed)
		# Sprint
		if Input.is_action_pressed("sprint"):
			current_speed = lerp(current_speed, SPRINT_SPEED, delta * lerp_speed)
			
			walking = false
			sprinting = true
			crouching = false
		else:
			current_speed = lerp(current_speed, WALK_SPEED, delta * lerp_speed)
			
			walking = true
			sprinting = false
			crouching = false
	
	# Handle Free Look
	if Input.is_action_pressed("free_look") or sliding:
		free_looking = true
		if sliding:
			eyes.rotation.z = lerp(eyes.rotation.z,-deg_to_rad(7.0), delta * lerp_speed )
		else:
			eyes.rotation.z = -deg_to_rad(neck.rotation.y * free_look_tilt_amount)
			
	else:
		free_looking = false
		neck.rotation.y = lerp(neck.rotation.y,0.0, delta * lerp_speed)
		eyes.rotation.z = lerp(eyes.rotation.z,0.0, delta * lerp_speed)
		
	# Handle Sliding
	if sliding:
		slide_timer -= delta
		if slide_timer <= 0:
			sliding = false
			free_looking = false
			
	if Input.is_action_pressed("look_back"):
		looking_back = true
		neck.rotation.y = lerp(neck.rotation.y, deg_to_rad(-300.0), delta * lerp_speed)
	else:
		looking_back = false
		neck.rotation.y = lerp(neck.rotation.y,0.0, delta * lerp_speed)
		
	# Handle Headbob
	if sprinting:
		head_bobbing_current_intensity = HEAD_BOBBING_SPRINT_INTENSITY
		head_bobbing_index += HEAD_BOBBING_SPRINT_SPEED * delta
	elif walking:
		head_bobbing_current_intensity = HEAD_BOBBING_WALK_INTENSITY
		head_bobbing_index += HEAD_BOBBING_WALK_SPEED * delta
	elif crouching:
		head_bobbing_current_intensity = HEAD_BOBBING_CROUCH_INTENSITY
		head_bobbing_index += HEAD_BOBBING_CROUCH_SPEED * delta
	
	if is_on_floor() and !sliding and input_dir != Vector2.ZERO:
		head_bobbing_vector.y = sin(head_bobbing_index)
		head_bobbing_vector.x = sin(head_bobbing_index/2) + 0.5
		
		eyes.position.y = lerp(eyes.position.y, head_bobbing_vector.y * (head_bobbing_current_intensity/2.0), delta * lerp_speed)
		eyes.position.x = lerp(eyes.position.x, head_bobbing_vector.x * head_bobbing_current_intensity, delta * lerp_speed)
	else:
		eyes.position.y = lerp(eyes.position.y, 0.0, delta * lerp_speed)
		eyes.position.x = lerp(eyes.position.x, 0.0, delta * lerp_speed)

	# Add the gravity.
	if not is_on_floor():
		velocity += get_gravity() * delta

	# Handle jump.
	if Input.is_action_just_pressed("jump") and is_on_floor():
		velocity.y = JUMP_VELOCITY
		sliding = false
		animation_player.play("jump")
		
	#Handle landing anims
	if is_on_floor():
		if last_velocity.y < -4.0:
			animation_player.play("landing")

	if is_on_floor():
		direction = lerp(direction, (transform.basis * Vector3(input_dir.x, 0, input_dir.y)).normalized(), delta * lerp_speed)
	else:
		if input_dir != Vector2.ZERO:
			direction = lerp(direction, (transform.basis * Vector3(input_dir.x, 0, input_dir.y)).normalized(), delta * air_lerp_speed)
		
	if sliding:
		direction = (transform.basis * Vector3(slide_vector.x, 0.0, slide_vector.y)).normalized()
		current_speed = (slide_timer + 0.1) * SLIDE_SPEED
	
	if direction:
		velocity.x = direction.x * current_speed
		velocity.z = direction.z * current_speed
		
	else:
		velocity.x = move_toward(velocity.x, 0, current_speed)
		velocity.z = move_toward(velocity.z, 0, current_speed)
	last_velocity = velocity
	move_and_slide()
	
