#TODO: If the player rotates, the model rotates
# Character3D
#	CollisionShape3D
#	Node3D(Head)
#		Camera3D
extends CharacterBody3D

var speed 
const WALK_SPEED = 5.0
const SPRINT_SPEED = 8.0

# create a bob feel
const BOB_FREQ = 2.0
const BOB_AMP = 0.08
var t_bob = 0.0

var gravity = 9.8
const SENSITIVITY = 0.003

#fov 
const BASE_FOV = 75.0
const FOV_CHANGE = 1.5

# Be sure to match this with the project
@onready var head = $Head
@onready var camera = $Head/Camera3D

func _ready() -> void:
	Input.set_mouse_mode(Input.MOUSE_MODE_CAPTURED)

#to rotate the camere
func _unhandled_input(event: InputEvent) -> void:
	if event is InputEventMouseMotion:
		head.rotate_y(-event.relative.x * SENSITIVITY)
		camera.rotate_x(-event.relative.y * SENSITIVITY)
		# limit the camera
		camera.rotation.x = clamp(camera.rotation.x, deg_to_rad(-40), deg_to_rad(60))
		# dont know why this dont work
		camera.rotation.y = clamp(camera.rotation.y, deg_to_rad(-90), deg_to_rad(90))

func _physics_process(delta: float) -> void:
	# Add the gravity.
	if not is_on_floor():
		velocity.y -= gravity * delta

	if Input.is_action_pressed("sprint"):
		speed = SPRINT_SPEED
	else:
		speed = WALK_SPEED

	# Get the input direction and handle the movement/deceleration.
	# As good practice, you should replace UI actions with custom gameplay actions.
	var input_dir := Input.get_vector("left", "right", "up", "down")
	var direction = (head.transform.basis * Vector3(input_dir.x, 0, input_dir.y)).normalized()
	
	# Inertia
	if is_on_floor():
		if direction:
			velocity.x = direction.x * speed 
			velocity.z = direction.z * speed 
		else:
			velocity.x = lerp(velocity.x, direction.x * speed, delta * 7.0)
			velocity.z = lerp(velocity.z, direction.z * speed, delta * 7.0)
	else:
		velocity.x = lerp(velocity.x, direction.x * speed, delta * 3.0)
		velocity.z = lerp(velocity.z, direction.z * speed, delta * 3.0)

	#headbob
	t_bob += delta * velocity.length() * float(is_on_floor()) 
	camera.transform.origin = _headbob(t_bob)

	#fov change
	var velocity_clamped = clamp(velocity.length(),0.5, SPRINT_SPEED * 2)
	var target_fov = BASE_FOV + FOV_CHANGE * velocity_clamped

	camera.fov = lerp(camera.fov, target_fov, delta * 8.0)

	move_and_slide()

func _headbob(time) -> Vector3:
	var pos = Vector3.ZERO
	pos.y = sin(time * BOB_FREQ) * BOB_AMP #sine wave
	pos.x = cos(time* BOB_FREQ/2) * BOB_AMP
	return pos
