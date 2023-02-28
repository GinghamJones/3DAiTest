extends Control
@onready var player : CharacterBody3D = get_tree().get_first_node_in_group("Player")
@onready var ai : Array = get_tree().get_nodes_in_group("AI")

func _ready() -> void:
	$AISettings/Speed/HSlider.value = ai[0].max_speed
	$PlayerSettings/PlayerSpeed/SpeedSlider.value = player.speed


func _unhandled_input(event: InputEvent) -> void:
	if event.is_action_pressed("Pause"):
		get_tree().paused = false
		Input.set_mouse_mode(Input.MOUSE_MODE_CAPTURED)
		get_viewport().set_input_as_handled()
		queue_free()

func _on_h_slider_value_changed(value: float) -> void:
	$AISettings/Speed.set_text("Speed = " + str(value))
	
	for dude in ai:
		dude.max_speed = value


func _on_speed_slider_value_changed(value: float) -> void:
	$PlayerSettings/PlayerSpeed.set_text("Speed = " + str(value))
	player.speed = value
