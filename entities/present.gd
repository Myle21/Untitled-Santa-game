extends Area2D

func _ready():
	$Present.set_texture(load("res://assets/present/present%d.png" % randi_range(1,3)))

func _on_body_entered(body):
	body.collect_present()
	queue_free()
