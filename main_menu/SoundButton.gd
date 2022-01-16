extends Button


func _ready() -> void:
	var _error1 = connect("pressed", GlobalValues, "toggle_sound")
	var _error2 = connect("pressed", self, "update_text")
	update_text()


func update_text() -> void:
	if GlobalValues.sound_muted:
		set_text("Sound: OFF")
	else:
		set_text("Sound: ON")
