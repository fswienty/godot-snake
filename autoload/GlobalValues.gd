extends Node

# in px, depends on the size of the used pictures
const sprite_size: int = 64

# in px, varies with the size of the grid
var tile_size: float = 1

var advance_time: float = 1
var grid_size: Vector2

# scale of the tiles so that the sprites are tile_size px in size
var scale: Vector2 = Vector2(1, 1) setget set_discard, get_scale

var music_muted: bool = false
var sound_muted: bool = false
var is_fullscreen: bool = false


func _ready() -> void:
	AudioServer.set_bus_mute(1, music_muted)
	AudioServer.set_bus_mute(2, sound_muted)


func get_scale() -> Vector2:
	return Vector2.ONE * tile_size / sprite_size


func toggle_music() -> void:
	music_muted = !music_muted
	AudioServer.set_bus_mute(1, music_muted)


func toggle_sound() -> void:
	sound_muted = !sound_muted
	AudioServer.set_bus_mute(2, sound_muted)


func toggle_fullscreen() -> void:
	is_fullscreen = !is_fullscreen
	OS.window_fullscreen = is_fullscreen


func set_discard(_vec: Vector2) -> void:
	print("please don't set me")
