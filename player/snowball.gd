extends Area2D

@export var speed : float = 100
@export var direction : Vector2
@onready var particles = $GPUParticles2D

@onready var player : CharacterBody2D

func _ready():
	player = get_tree().get_first_node_in_group("player")
	particles.process_material.gravity.x = direction.x * -30

func _physics_process(delta):
	if is_instance_valid(player):
		var distance = global_position.distance_to(player.global_position)
		if distance > 600 || distance < -600:
			queue_free()
		position.x += direction.x * speed * delta
	


func _on_body_entered(body):
	if body.is_in_group("enemy"):
		body.damage(1)
	queue_free()
