extends CharacterBody3D

# Player Nodes
@onready var head: Node3D = $head
@onready var standing_collision_shape: CollisionShape3D = $standing_collision_shape
@onready var crouching_collision_shape: CollisionShape3D = $crouching_collision_shape
@onready var collision_detection: RayCast3D = $collision_detection


# Speed Vars
var current_speed :float = 5.0
const WALK_SPEED :float = 5.0
const SPRINT_SPEED :float = 8.0
const CROUCH_SPEED :float = 3.0

# Movement Vars
var crouching_depth = -0.5
const JUMP_VELOCITY :float = 4.5

#Input VarINERTIA 
var lerp_speed : float = 10.0
var direction : Vector3
const MOUSE_SENSITIVITY = 0.1

func _ready() -> void:
	Input.mouse_mode = Input.MOUSE_MODE_CAPTURED
	
	if Input.is_action_just_pressed("quit"):
		pass

func _input(event: InputEvent) -> void:
	if event is InputEventMouseMotion:
		rotate_y(deg_to_rad(-event.relative.x * MOUSE_SENSITIVITY))
		head.rotate_x(deg_to_rad(-event.relative.y * MOUSE_SENSITIVITY))
		head.rotation.x = clamp(head.rotation.x, deg_to_rad(-60), deg_to_rad(80))

func _physics_process(delta: float) -> void:
	# Handling Movement State
	
	# Crouching
	if Input.is_action_pressed("crouch"):
		current_speed = CROUCH_SPEED
		head.position.y = lerp(head.position.y, 1.8 + crouching_depth, delta * lerp_speed)
		standing_collision_shape.disabled = true
		crouching_collision_shape.disabled = false
	elif !collision_detection.is_colliding():
		# Standing
		standing_collision_shape.disabled = false 
		crouching_collision_shape.disabled = true 
		head.position.y = lerp(head.position.y, 1.8, delta * lerp_speed)
		# Sprint
		if Input.is_action_pressed("sprint"):
			current_speed = SPRINT_SPEED
		else:
			current_speed = WALK_SPEED
		
	# Add the gravity.
	if not is_on_floor():
		velocity += get_gravity() * delta

	# Handle jump.
	if Input.is_action_just_pressed("ui_accept") and is_on_floor():
		velocity.y = JUMP_VELOCITY

	# Get the input direction and handle the movement/deceleration.
	# As good practice, you should replace UI actions with custom gameplay actions.
	var input_dir := Input.get_vector("left", "right", "forward", "backward")
	direction = lerp(direction, (transform.basis * Vector3(input_dir.x, 0, input_dir.y)).normalized(), delta * lerp_speed)
	
	
	
	if direction:
		velocity.x = direction.x * current_speed
		velocity.z = direction.z * current_speed
	else:
		velocity.x = move_toward(velocity.x, 0, current_speed)
		velocity.z = move_toward(velocity.z, 0, current_speed)

	move_and_slide()
