extends Node

@export var volume : float = -10
@onready var audio = $AudioStreamPlayer2
@onready var music = $AudioStreamPlayer
var current_prioritet : int = 0

func _process(delta):
	music.volume_db = volume

func add_sound(sound, prioritet : int , volume_float : float):
	if !audio.is_playing() or prioritet > current_prioritet:
		current_prioritet = prioritet
		audio.set_stream(sound)
		audio.volume_db = volume + volume_float
		audio.play()

func music_state(state : bool):
	music.playing = state
