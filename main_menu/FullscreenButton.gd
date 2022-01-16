extends Button


func _ready() -> void:
	var _error1 = connect("pressed", GlobalValues, "toggle_fullscreen")
	var _error2 = connect("pressed", self, "update_text")
	update_text()


func update_text() -> void:
	if GlobalValues.is_fullscreen:
		set_text("Fullscreen: ON")
	else:
		set_text("Fullscreen: OFF")
