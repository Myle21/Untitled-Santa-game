extends CharacterBody2D

signal dead
signal won

@export var jump_height : float = 200
@export var jump_time_to_peak : float = 0.6
@export var jump_time_to_descent : float = 0.5
@export var coyote_time : float = 0.1
@export var SPEED : float = 125
@export var HEALTH : int = 3
@export var presents : int = 0
@export var presents_amnt : int = 6

@export var is_able_to_jump : bool = true

@onready var jump_velocity : float = ((2.0 * jump_height) / jump_time_to_peak) * -1
@onready var jump_gravity : float = ((-2.0 * jump_height) / pow(jump_time_to_peak, 2)) * -1
@onready var fall_gravity : float = ((-2.0 * jump_height) / pow(jump_time_to_descent, 2)) * -1
@onready var sprite = $sprite

@onready var coyote_timer = $coyote_timer

@onready var snowball = preload("res://player/snowball.tscn")
const win = preload("res://audio_server/sounds/win.wav")
const damage_snd = preload("res://audio_server/sounds/damage.wav")
const footsteps = preload("res://audio_server/sounds/footsteps.wav")
const jump_snd = preload("res://audio_server/sounds/jump.wav")
const death = preload("res://audio_server/sounds/lose.wav")
const shoot = preload("res://audio_server/sounds/shoot.wav")
const collect_point = preload("res://audio_server/sounds/collect_point.wav")
var audio_server : Node

enum state_list {idle, walking, jumping, throw}
var state = state_list.idle

var last_dir : float = 1

func _ready():
	audio_server = get_tree().get_first_node_in_group("audio")

func _physics_process(delta):
	fix_camera_jitter()
	handle_coyote()
	handle_controls()
	handle_gravity(delta)
	move_and_slide()
	handle_animations()

func get_gravity() -> float:
	return jump_gravity if velocity.y < 0 else fall_gravity

func handle_controls() -> void:
	if Input.is_action_pressed("down"):

		set_collision_mask_value(2, false)
	else:
		set_collision_mask_value(2, true )
	
	if Input.is_action_just_pressed("jump") and is_able_to_jump:
		jump()
	if Input.is_action_just_released("jump"):
		jump_cut()
	
	var direction : float = Input.get_axis("left","right")
	
	handle_movement(direction)
	
	if Input.is_action_just_pressed("throw"):
		throw_snowball()

func handle_gravity(delta) -> void:
	velocity.y += get_gravity() * delta

func handle_coyote() -> void:
	if is_on_floor() && !is_able_to_jump:
		is_able_to_jump = true
	elif is_able_to_jump and coyote_timer.is_stopped():
		coyote_timer.start(coyote_time)

func jump() -> void:
	audio_server.add_sound(jump_snd, 7, 0)
	set_state(state_list.jumping)
	velocity.y = jump_velocity

func jump_cut() -> void:
	if velocity.y < 0:
		velocity.y = velocity.y /5

func _on_coyote_timeout() -> void:
	is_able_to_jump = false
	
func fix_camera_jitter():
	$Camera.position = round($Camera.position)

func handle_animations():
	match state:
		0:
			sprite.play("idle")
		1:
			sprite.play("run")
		2:
			sprite.play("jump_air")
		3:
			sprite.play("throw")
			handle_throw()

func set_state(state_name):
	state = state_name

func throw_snowball():
	if $cooldown.is_stopped():
		set_state(state_list.throw)

func handle_movement(direction):
	if direction:
		if is_on_floor():
			audio_server.add_sound(footsteps, 3, 10)
		last_dir = direction
		if is_on_floor():
			if state != 3:
				set_state(state_list.walking)
		else:
			if state != 3:
				set_state(state_list.jumping)
		if direction > 0:
			sprite.flip_h = false
		else: if direction < 0:
			sprite.flip_h = true
		velocity.x = direction * SPEED
	else:
		if is_on_floor():
			if state != 3:
				set_state(state_list.idle)
			velocity.x = lerp(velocity.x, 0.0, 0.75)
		else:
			if state != 3:
				set_state(state_list.jumping)
			velocity.x = lerp(velocity.x, 0.0, 0.05)

func damage(value):
	if $iframe.is_stopped():
		sprite.get_material().set_shader_parameter("is_immunity_active", true)
		audio_server.add_sound(damage_snd, 10, 10)
		HEALTH -= value
		$iframe.start(0.1)
		if HEALTH < 1:
			audio_server.music_state(false)
			audio_server.add_sound(death, 69, 0)
			emit_signal("dead")
			queue_free()

func collect_present():
	audio_server.add_sound(collect_point, 8, 10)
	presents += 1
	if presents >= presents_amnt:
		emit_signal("won")
		audio_server.add_sound(win, 69, 0)

func _on_iframe_timeout():
	sprite.get_material().set_shader_parameter("is_immunity_active", false)

func _on_sprite_animation_finished():
	set_state(state_list.idle)
	
func handle_throw():
	if sprite.animation == "throw":
		if sprite.get_frame() >= 4:
			if $cooldown.is_stopped():
				audio_server.add_sound(shoot, 7, 10)
				var snowball_instance = snowball.instantiate()
				snowball_instance.direction.x = last_dir
				snowball_instance.global_position = global_position
				add_sibling(snowball_instance)
				$cooldown.start(0.3)
