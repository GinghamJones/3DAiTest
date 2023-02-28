extends CharacterBody3D

@onready var camera_helper : Node3D = $CamRotationHelper
@onready var spring_arm : SpringArm3D = $CamRotationHelper/SpringArm3D
@onready var pause_menu : PackedScene = preload("res://Scenes/pause_menu.tscn")
@onready var smoke_particles : GPUParticles3D = $WalkSmoke
@onready var anims : AnimationPlayer = $AnimationPlayer

@export var speed : float = 5.0
@export var look_speed : float = 0.2
@export var acceleration : float = 2.0
@export var jump_force : float = 15
@export var gravity : float = 6.0

const MAX_LOOK_ANGLE : int = 60
const MIN_LOOK_ANGLE : int = -60

var mouse_delta : Vector2
var is_paused : bool = false
var is_jumping : bool = false


func _ready() -> void:
	Input.mouse_mode = Input.MOUSE_MODE_CAPTURED
	smoke_particles.emitting = false
	
	
func _unhandled_input(event: InputEvent) -> void:
	if event is InputEventMouseMotion and Input.MOUSE_MODE_CAPTURED:
		mouse_delta = event.relative

	if event.is_action("ZoomIn"):
		spring_arm.position.z +=  -0.1
	if event.is_action("ZoomOut"):
		spring_arm.position.z += 0.1
	
	if event.is_action_pressed("Pause"):
		handle_pause()
		
	if event.is_action_pressed("Jump"):
		is_jumping = true
	if event.is_action_released("Jump"):
		is_jumping = false
	
	if event.is_action_pressed("Attack"):
		anims.play("Swing")

func _process(delta: float) -> void:
	#Rotate camera
	camera_helper.rotation -= Vector3(mouse_delta.y, 0, 0) * look_speed * delta
	camera_helper.rotation.x = clamp(camera_helper.rotation.x, deg_to_rad(MIN_LOOK_ANGLE), deg_to_rad(MAX_LOOK_ANGLE))
	if velocity.length() > 2:
		rotation -= Vector3(0, mouse_delta.x, 0) * look_speed * delta
	else:
		camera_helper.rotation.y -= mouse_delta.x * look_speed * delta
		if Input.get_vector("MoveForward", "MoveBackward", "MoveLeft", "MoveRight") != Vector2.ZERO:
			global_rotation.y = camera_helper.global_rotation.y
			camera_helper.rotation.y = 0

	mouse_delta = Vector2()


func _physics_process(delta: float) -> void:
	move_my_ass()
	am_i_smokin()


func move_my_ass():
	var input_dir : Vector2 = Input.get_vector("MoveLeft", "MoveRight", "MoveForward", "MoveBackward")
	var direction : Vector3 = (transform.basis * Vector3(input_dir.x, 0, input_dir.y)).normalized()
	var target_velocity : Vector3 = direction * speed
	
	
	target_velocity.y = 0
	
	if not is_on_floor():
		target_velocity.y -= gravity 
	
	velocity = lerp(velocity, target_velocity, acceleration)
	
	if velocity.length() > speed:
		velocity = velocity.normalized() * speed
	
	if is_jumping:
		target_velocity.y = jump_force
		velocity.y = lerp(velocity.y, target_velocity.y, acceleration)
		if global_position.y > 5:
			is_jumping = false
			
	move_and_slide()


func handle_pause():
	Input.mouse_mode = Input.MOUSE_MODE_VISIBLE
	var menu = pause_menu.instantiate()
	get_tree().root.add_child(menu)
	get_tree().paused = true


func am_i_smokin():
	var xz_velocity : Vector2 = Vector2(velocity.x, velocity.z)
	if xz_velocity.length() > 0.5 and not is_jumping:
		smoke_particles.emitting = true
	else:
		smoke_particles.emitting = false
