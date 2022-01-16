extends Button


func _ready() -> void:
	var _error1 = connect("pressed", GlobalValues, "toggle_music")
	var _error2 = connect("pressed", self, "update_text")
	update_text()


func update_text() -> void:
	if GlobalValues.music_muted:
		set_text("Music: OFF")
	else:
		set_text("Music: ON")
