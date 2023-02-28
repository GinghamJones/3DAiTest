extends CharacterBody3D

@onready var player : CharacterBody3D = get_tree().get_first_node_in_group("Player")
var is_navigating : bool = false
var max_speed : float = 4.0
var acceleration : float = 1.5
var gravity : float = 4.0
var jump_force : float = 10

func _unhandled_input(event: InputEvent) -> void:
	if event.is_action_pressed("GO"):
		is_navigating = not is_navigating


func _physics_process(delta: float) -> void:
	if is_navigating:
		var target : Vector3 = player.global_position + Vector3(0, 0.5, 0)
		var distance : Vector3 = target - global_position
		var direction : Vector3 = distance.normalized()
		
		var target_velocity : Vector3 = direction * max_speed
		velocity = velocity.lerp(target_velocity, acceleration)
		look_at(target)
		move_and_slide()


func new_orientation(current : float) -> float:
	if velocity.length() > 0:
		return atan2(-velocity.x, -velocity.z)
	else:
		return current

