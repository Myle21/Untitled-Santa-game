extends CharacterBody2D

@export var jump_height : float = 200
@export var jump_time_to_peak : float = 0.6
@export var jump_time_to_descent : float = 0.5

@onready var jump_velocity : float = ((2.0 * jump_height) / jump_time_to_peak) * -1
@onready var jump_gravity : float = ((-2.0 * jump_height) / pow(jump_time_to_peak, 2)) * -1
@onready var fall_gravity : float = ((-2.0 * jump_height) / pow(jump_time_to_descent, 2)) * -1

enum state {IDlE, AGGRO}
var current_state = state.IDlE

func _physics_process(delta):
	velocity.x = 50
	move_and_slide()

func jump() -> void:
	velocity.y = jump_velocity

func handle_gravity(delta) -> void:
	velocity.y += get_gravity() * delta
	
func get_gravity() -> float:
	return jump_gravity if velocity.y < 0 else fall_gravity

func change_state(state_name) -> void:
	current_state = state_name


func _on_area_2d_body_exited(body):
	print(body)
