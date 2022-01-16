class_name Player
extends Node2D

signal lost
signal ate

export(PackedScene) var BodyPart

var needs_growing: bool = false
var length: int = 0
var input_queuings: int = 0

const HEAD_Z_INDEX: int = 10

var last_direction: Vector2 = Vector2.ZERO  # direction the snake advanced in last
var next_direction: Vector2 = Vector2.ZERO  # direction the snake is supposed to advance in the next step
var queued_next_direction: Vector2 = Vector2.ZERO

var last_part: BodyPart  # the tail end part of the snake


func init(start_position: Vector2, start_direction: Vector2, initial_length: int) -> void:
	print("Player init")
	$Head.grid_position = start_position
	$Head.next_grid_position = start_position + start_direction
	$Head.add_to_group("body_parts")
	$Head.z_index = HEAD_Z_INDEX
	$Head.scale = GlobalValues.scale
	$Head.position = $Head.grid_position * GlobalValues.tile_size
	last_part = $Head  # head is initially the last part
	next_direction = start_direction

	# add initial tail
	for _i in range(initial_length):
		var new_part = grow()
		new_part.grid_position = (last_part.grid_position - start_direction)
		new_part.position = new_part.grid_position * GlobalValues.tile_size
		new_part.rotation = start_direction.angle() + PI / 2


func update() -> void:
	# add a body part at the end if food was eaten
	if needs_growing:
		needs_growing = false
		var _new_part = grow()

	# set next position of the head
	$Head.next_grid_position = $Head.grid_position + next_direction
	last_direction = next_direction

	# handle queued input if present
	if queued_next_direction != Vector2.ZERO:
		next_direction = queued_next_direction
		queued_next_direction = Vector2.ZERO
		input_queuings += 1
		print("Input queueing saved the day %s times!" % input_queuings)


func grow() -> BodyPart:
	length += 1
	var new_part: BodyPart = BodyPart.instance() as BodyPart
	add_child(new_part)
	new_part.add_to_tail(last_part)
	new_part.z_index = HEAD_Z_INDEX - length
	last_part = new_part
	return new_part


func _process(_delta: float) -> void:
	# get input
	var input_direction: Vector2 = Vector2.ZERO
	if Input.is_action_just_pressed("ui_up"):
		input_direction = Vector2.UP
	if Input.is_action_just_pressed("ui_down"):
		input_direction = Vector2.DOWN
	if Input.is_action_just_pressed("ui_left"):
		input_direction = Vector2.LEFT
	if Input.is_action_just_pressed("ui_right"):
		input_direction = Vector2.RIGHT

	# save input for the next advence step if valid
	if input_direction != Vector2.ZERO:
		if is_perp(input_direction, last_direction):
			next_direction = input_direction
			queued_next_direction = Vector2.ZERO
		elif is_perp(input_direction, next_direction):
			queued_next_direction = input_direction


func is_perp(vec1: Vector2, vec2: Vector2) -> bool:
	return vec1.dot(vec2) == 0


func get_occupied_positions() -> Array:
	var body_parts = get_tree().get_nodes_in_group("body_parts")
	var occupied_positions: Array = []
	for body_part in body_parts:
		occupied_positions.append(body_part.grid_position)
	return occupied_positions


func _on_Head_area_entered(area: Area2D) -> void:
	var groups: Array = area.get_groups()
	if "body_parts" in groups or "obstacles" in groups:
		emit_signal("lost")
	elif "food" in groups:
		emit_signal("ate")
		needs_growing = true
		area.get_node("FoodEffects").play()
		area.queue_free()
	else:
		print("hit a tile that wasnt defined in _on_Head_area_entered in player script")
