extends Node2D

@onready var label = $"UI/HBoxContainer/MarginContainer/Label"
@onready var presents_count = $"UI/HBoxContainer/MarginContainer2/Presents count"
@onready var win = preload("res://win.tscn")
var player : CharacterBody2D

func _ready():
	player = get_tree().get_first_node_in_group("player")
	var target_fps : float = DisplayServer.screen_get_refresh_rate(1)
	Engine.physics_ticks_per_second = target_fps
	Engine.max_fps = target_fps

func _process(_delta):
	if is_instance_valid(player):
		label.text = str("x%s"%player.HEALTH)
		presents_count.text = "Presents: %s"%player.presents
	else: label.text = ""
	

func _on_area_2d_body_entered(body):
	if body.is_in_group("player") or body.is_in_group("enemy"):
		body.damage(69)

func _on_player_dead():
	$Control.visible = true
	$UI.visible = false

func _on_player_won():
	var instance = win.instantiate()
	add_child(instance)
	player.process_mode = Node.PROCESS_MODE_DISABLED
	$AudioServer.music_state(false)
