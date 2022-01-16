extends Particles2D


func play() -> void:
	var world_pos: Vector2 = global_position
	get_parent().remove_child(self)
	TemporaryNodes.add_child(self)
	scale = GlobalValues.scale
	position = world_pos
	var timer: Timer = Timer.new()
	var _err = timer.connect("timeout", self, "_on_timer_timeout")
	add_child(timer)
	timer.wait_time = lifetime + 2
	timer.start()
	emitting = true
	$EatSound.play()


func _on_timer_timeout() -> void:
	self.queue_free()
