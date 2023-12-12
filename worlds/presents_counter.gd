extends Node2D

@export var present_ammount : int = 1

func _ready():
	get_tree().get_first_node_in_group("player").presents_amnt = present_ammount
