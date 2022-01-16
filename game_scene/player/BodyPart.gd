class_name BodyPart
extends Area2D

var next_grid_position: Vector2
var grid_position: Vector2
var previous_grid_position: Vector2
var previous_part: BodyPart

var last_direction: Vector2 = Vector2.ZERO  # direction the snake advanced in last


func add_to_tail(previous_body_part) -> void:
	add_to_group("body_parts")
	previous_part = previous_body_part
	grid_position = previous_body_part.grid_position
	next_grid_position = previous_body_part.grid_position
	previous_grid_position = grid_position
	scale = GlobalValues.scale
	position = grid_position * GlobalValues.tile_size
	rotation = previous_body_part.rotation


func pre_advance() -> void:
	if next_grid_position.x > GlobalValues.grid_size.x - 1:
		grid_position.x = -1
		next_grid_position.x = 0
		position.x = grid_position.x * GlobalValues.tile_size

	if next_grid_position.x < 0:
		grid_position.x = GlobalValues.grid_size.x
		next_grid_position.x = GlobalValues.grid_size.x - 1
		position.x = grid_position.x * GlobalValues.tile_size

	if next_grid_position.y > GlobalValues.grid_size.y - 1:
		grid_position.y = -1
		next_grid_position.y = 0
		position.y = grid_position.y * GlobalValues.tile_size

	if next_grid_position.y < 0:
		grid_position.y = GlobalValues.grid_size.y
		next_grid_position.y = GlobalValues.grid_size.y - 1
		position.y = grid_position.y * GlobalValues.tile_size

	if previous_part != null:
		if grid_position.distance_to(previous_part.grid_position) > 1:
			grid_position = previous_part.previous_grid_position
			position = grid_position * GlobalValues.tile_size


func advance() -> void:
	# update position
	previous_grid_position = grid_position
	grid_position = next_grid_position

	$PositionTween.interpolate_property(
		self,
		"position",
		null,
		grid_position * GlobalValues.tile_size,
		1 * GlobalValues.advance_time,
		Tween.TRANS_CUBIC,
		Tween.EASE_IN_OUT
	)
	$PositionTween.start()

	# rotation stuff
	last_direction = (grid_position - previous_grid_position).normalized()
	if previous_part != null:
		next_grid_position = previous_part.grid_position

		# find out if there was a change of direction and rotate the body part appropriately
		var rotation_degrees_delta: float = 0
		var next_direction = previous_part.last_direction
		if last_direction.is_equal_approx(next_direction.rotated(PI / 2)):
			rotation_degrees_delta = -90
		if last_direction.is_equal_approx(next_direction.rotated(-PI / 2)):
			rotation_degrees_delta = 90
		$RotationTween.interpolate_property(
			self,
			"rotation_degrees",
			null,
			stepify(rotation_degrees + rotation_degrees_delta, 90),
			1 * GlobalValues.advance_time,
			Tween.TRANS_CUBIC,
			Tween.EASE_IN_OUT
		)
		$RotationTween.start()
