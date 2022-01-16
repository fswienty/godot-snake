extends AudioStreamPlayer

export var music_path: String


func _ready():
	if File.new().file_exists(music_path):
		var sfx = load(music_path)
		sfx.set_loop(true)
		stream = sfx
		play()
