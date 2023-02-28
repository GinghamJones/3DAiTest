extends CharacterBody3D

@onready var head : MeshInstance3D = $Head
@onready var navigation : NavigationAgent3D = $NavigationAgent3D
@onready var raycast : RayCast3D = $RayCast3D
@onready var smoke : GPUParticles3D = $WalkSmoke

var is_navigating : bool = false
var max_speed : float = 4.0
var wander_speed : float = 1.0
var acceleration : float = 1.5
var gravity : float = 4.0
var jump_force : float = 10

enum {
	WANDERING,
	PURSUING,
	IDLE,
	AVOIDING,
	ATTACKING,
}

var state = WANDERING
var need_target : bool = true
var idle_time : float = 0
var idle_rot_dir : int = 1
var idle_passes : int = 0
var player : CharacterBody3D

func _unhandled_input(event: InputEvent) -> void:
	if event.is_action_pressed("GO"):
		is_navigating = not is_navigating


func _physics_process(delta: float) -> void:
	if is_navigating:
		match state:
			WANDERING:
				wander()
			PURSUING:
				pursue()
			IDLE:
				idle(delta)
			AVOIDING:
				pass
			ATTACKING:
				pass
		#rotation.y = new_orientation(rotation.y)


## State Functions ##

func wander():
	if need_target:
		var radius : float = 2.0
		var random_position = Vector3(randf_range(-radius, radius), 0, randf_range(-radius, radius))
		navigation.set_target_position(random_position)
		need_target = false
	
	navigate_my_ass(wander_speed)
	
	if navigation.is_navigation_finished():
		state = IDLE
		need_target = true


func pursue():
	var prediction = 0.1
	navigation.set_target_position(player.global_position + (player.velocity * prediction))
	navigate_my_ass(max_speed)


func avoiding(target):
	pass


func idle(delta):
	if idle_time < 2.5:
		idle_time += delta
		head.rotation.y += delta * idle_rot_dir
	else:
		idle_time = 0
		idle_passes += 1
		idle_rot_dir *= -1
	
	if idle_passes == 4:
		idle_passes = 0
		head.rotation.y = 0
		state = WANDERING
		

## End State Functions ##


func navigate_my_ass(speed):
	var current_position : Vector3 = global_position
	var next_position : Vector3 = navigation.get_next_path_position()
	
	var target_velocity = (next_position - current_position).normalized() 
	target_velocity *= speed
	target_velocity.y = 0
	
	navigation.set_velocity(target_velocity)
	await navigation.velocity_computed
	
	if not is_on_floor():
		velocity.y -= gravity 
		
	rotation.y = new_orientation(rotation.y)
	
	move_and_slide()
	do_smoke()
	

func new_orientation(current : float) -> float:
	if velocity.length() > 0:
		return atan2(-velocity.x, -velocity.z)
	else:
		return current


func do_smoke():
	if velocity.length() > 2.0:
		smoke.emitting = true
	else:
		smoke.emitting = false


func _on_navigation_agent_3d_velocity_computed(safe_velocity: Vector3) -> void:
	velocity = safe_velocity


func _on_detection_area_body_entered(body: Node3D) -> void:
	if body.is_in_group("Player"):
		player = body
		state = PURSUING


func _on_detection_area_body_exited(body: Node3D) -> void:
	if player != null:
		player = null
		state = IDLE

