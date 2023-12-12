extends CharacterBody2D

enum state {idle, aggro, notice_player}

@export var speed : float = 25
var HEALTH : int = 3

const max_speed : float = 125.0

var current_state = state.idle

@export var direction : float = -1
@export var jump_height : float = 50
@export var jump_time_to_peak : float = 0.3
@export var jump_time_to_descent : float = 0.2

@onready var jump_velocity : float = ((2.0 * jump_height) / jump_time_to_peak) * -1
@onready var jump_gravity : float = ((-2.0 * jump_height) / pow(jump_time_to_peak, 2)) * -1
@onready var fall_gravity : float = ((-2.0 * jump_height) / pow(jump_time_to_descent, 2)) * -1

@onready var player_scan = $SnowBALLS/PlayerScan

func _physics_process(delta):
	handle_walls()
	handle_gravity(delta)
	handle_state(delta)
	move_and_slide()

func handle_state(delta) -> void:
	match current_state:
		0:
			handle_idle()
		1:
			handle_aggro(delta)
		2:
			handle_notice()

func set_state(state_name) -> void:
	current_state = state_name
	
func handle_idle() -> void:
	if player_scan.is_colliding():
		var body = player_scan.get_collider()
		if body.is_in_group("player"):
			set_state(state.notice_player)
	velocity.x = speed * direction

func handle_aggro(delta) -> void:
	$AnimationPlayer.play("aggro")
	speed += 25 * delta
	speed = clamp(speed, 25, max_speed)
	velocity.x = speed * direction
	
	$AnimationPlayer.speed_scale += 0.20 * delta
	$AnimationPlayer.speed_scale = clamp($AnimationPlayer.speed_scale, 0.5, 1) 
	
	scale += Vector2(0.25, 0.25) * delta
	scale = clamp(scale, Vector2(0.5, 0.5), Vector2(3,3))

func handle_notice() -> void:
	$AnimationPlayer.speed_scale = 1.75
	velocity.x = 0
	$AnimationPlayer.play("notice")

func get_gravity() -> float:
	return jump_gravity if velocity.y < 0 else fall_gravity

func handle_gravity(delta) -> void:
	velocity.y += get_gravity() * delta

func _on_animation_player_animation_finished(_anim_name):
	set_state(state.aggro)
	$AnimationPlayer.speed_scale = 0.5

func handle_rotation():
	if direction > 1:
		$SnowBALLS.flip_h = true
	else:
		$SnowBALLS.flip_h = false

func _on_area_2d_body_entered(body):
	if body.is_in_group("player"):
		body.damage(1)

func damage(value):
	$SnowBALLS.get_material().set_shader_parameter("is_immunity_active", true)
	HEALTH -= value
	if HEALTH < 1:
		queue_free()
	await get_tree().create_timer(0.1, true).timeout
	$SnowBALLS.get_material().set_shader_parameter("is_immunity_active", false)

func _on_visible_on_screen_enabler_2d_screen_entered():
	$SnowBALLS.get_material().set_shader_parameter("is_immunity_active", false)

func handle_walls():
	if $WallNotifier.is_colliding():
		$WallNotifier.rotate(PI)
		direction *= -1
		$SnowBALLS.flip_h = !$SnowBALLS.flip_h
		player_scan.rotate(PI)
