extends CharacterBody3D

@export var mouse_sens := 0.003
@export var walk_speed := 6.0
@export var sprint_speed := 9.0
@export var jump_velocity := 6.5
@export var gravity := 20.0

@onready var head: Node3D = $Head
@onready var cam: Camera3D = $Head/Camera3D

var yaw := 0.0
var pitch := 0.0

func _ready() -> void:
	print("Player script running")
	
	Input.set_mouse_mode(Input.MOUSE_MODE_CAPTURED)
	cam.current = true
	yaw = rotation.y
	pitch = head.rotation.x

func _unhandled_input(event: InputEvent) -> void:
	if event is InputEventMouseMotion:
		yaw -= event.relative.x * mouse_sens
		pitch = clamp(pitch - event.relative.y * mouse_sens, -1.2, 1.2)
		rotation.y = yaw
		head.rotation.x = pitch

	if event.is_action_pressed("ui_cancel"):
		Input.set_mouse_mode(Input.MOUSE_MODE_VISIBLE)

func _physics_process(delta: float) -> void:
	if not is_on_floor():
		velocity.y -= gravity * delta
	else:
		velocity.y = 0.0

	if is_on_floor() and Input.is_action_just_pressed("jump"):
		velocity.y = jump_velocity

	var input_dir := Vector3.ZERO
	var basis := global_transform.basis

	if Input.is_action_pressed("move_forward"): input_dir -= basis.z
	if Input.is_action_pressed("move_back"):    input_dir += basis.z
	if Input.is_action_pressed("move_left"):    input_dir -= basis.x
	if Input.is_action_pressed("move_right"):   input_dir += basis.x

	input_dir.y = 0.0
	input_dir = input_dir.normalized()

	var speed := walk_speed
	if Input.is_action_pressed("sprint"):
		speed = sprint_speed

	velocity.x = input_dir.x * speed
	velocity.z = input_dir.z * speed

	move_and_slide()
