extends AnimatableBody2D

var is_colliding : bool = false
@onready var init_pos = position
var delta_fake

func _physics_process(delta):
	delta_fake = delta
	if is_colliding:
		$AnimationPlayer.stop(true)
		position.y += 15 * delta

func _on_area_2d_body_entered(body):
	if body.is_in_group("player"):
		is_colliding = true

func _on_area_2d_body_exited(body):
	if body.is_in_group("player"):
		$Timer.start(0.5)

func _on_timer_timeout():
	is_colliding = false
	var tween = create_tween()
	tween.set_trans(tween.TRANS_CUBIC)
	tween.set_ease(Tween.EASE_IN_OUT)
	tween.tween_property(self, "position", init_pos, 1)
	await tween.finished
	$AnimationPlayer.play("float")


