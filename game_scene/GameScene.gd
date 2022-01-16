extends Node2D

export(PackedScene) var Food
export(PackedScene) var Obstacle

var all_positions: Array
var obstacle_positions: Array

var score: int = 0
onready var player: Player = $GridOffset/Player

const OBSTACLE_Z_INDEX: int = -4096

var default_level_path: String = "res://levels/level1.json"

# variables for gradually decreasing advance time
var initial_advance_time: float
var final_advance_time: float
var final_advance_time_score: float
var difficulty_formula_multiplier: float

var level_data: Dictionary
var layout: Array  # [rows/y, cols/x]
var grid_size: Vector2  # will be 30,16 @ 1080p and 64px tile size

onready var game_over_panel: Panel = $CanvasLayer/GameOverPanel
onready var game_over_score_label: Label = $CanvasLayer/GameOverPanel/ScoreContainer/Score
onready var score_label: Label = $CanvasLayer/ScorePanel/Score


func _ready() -> void:
	level_data = load_level_data()
	# initialize level specific stuff
	print("Initializing level: %s" % level_data.name)
	layout = level_data.layout
	var width = layout[0].size()
	var height = layout.size()
	grid_size = Vector2(width, height)
	GlobalValues.grid_size = grid_size
	print("Grid width: %s" % width)
	print("Grid height: %s" % height)

	# get screen size in pixels (-> 1920x1080)
	var screen_size: Vector2 = Vector2.ZERO
	screen_size.x = ProjectSettings.get_setting("display/window/size/width")
	screen_size.y = ProjectSettings.get_setting("display/window/size/height")

	# biggest tile size so that the entire grid fits the screen
	GlobalValues.tile_size = min(
		float(screen_size.x) / grid_size.x, float(screen_size.y) / grid_size.y
	)

	print("tile_size: %s px" % GlobalValues.tile_size)
	print("scale: %s" % GlobalValues.scale)

	# change position of the GridOffset node to center the grid
	# remainder in terms of tile sizes
	var margins: Vector2 = (screen_size / GlobalValues.tile_size) - grid_size
	# half-tile shift
	$GridOffset.position = Vector2.ONE * GlobalValues.tile_size / 2
	# shift grid in the middle
	$GridOffset.position += margins / 2 * GlobalValues.tile_size

	print("Grid Offset: ", $GridOffset.position)
	$Background.position_hider($GridOffset.position, grid_size)

	# prepare a list of all valid grid positions
	for col in range(grid_size.x):
		for row in range(grid_size.y):
			all_positions.append(Vector2(col, row))

	self.level_setup()


func load_level_data() -> Dictionary:
	# load json file
	var file = File.new()
	var level_json_path = SceneSwitcher.level_json_path
	if level_json_path == "":
		level_json_path = default_level_path
	file.open(level_json_path, File.READ)
	# parse json file
	var p: JSONParseResult = JSON.parse(file.get_as_text())
	# validation
	if p.error:
		print(p.result)
		push_error("Error in level json file.")
	else:
		print("Level loaded correctly.")
	return p.result


func level_setup() -> void:
	self.init_player()
	initial_advance_time = level_data.initial_advance_time
	final_advance_time = level_data.final_advance_time
	final_advance_time_score = level_data.final_advance_time_score
	difficulty_formula_multiplier = (
		(initial_advance_time - final_advance_time)
		/ pow(final_advance_time_score, 2)
	)
	update_difficulty()
	$AdvanceTimer.start()
	place_borders()
	for _i in range(level_data.food_amount):
		call_deferred("spawn_food")


func init_player() -> void:
	var start_pos: Vector2 = Vector2(0, 0)
	var start_dir: Vector2 = Vector2.RIGHT
	# get player start pos
	var finished = false
	for col in range(grid_size.x):
		for row in range(grid_size.y):
			if layout[row][col] == 2:
				start_pos = Vector2(col, row)
				finished = true
				break
		if finished:
			break
	# get player start direction
	if level_data.direction == "up":
		start_dir = Vector2.UP
	if level_data.direction == "down":
		start_dir = Vector2.DOWN
	if level_data.direction == "right":
		start_dir = Vector2.RIGHT
	if level_data.direction == "left":
		start_dir = Vector2.LEFT
	player.init(start_pos, start_dir, level_data.initial_length)


func place_borders() -> void:
	var border_positions: Array = []
	for col in range(grid_size.x):
		for row in range(grid_size.y):
			if layout[row][col] == 1:
				border_positions.append(Vector2(col, row))
	for pos in border_positions:
		place_obstacle(pos)


func place_obstacle(pos: Vector2) -> void:
	var obstacle: Area2D = Obstacle.instance()
	$GridOffset/Obstacles.add_child(obstacle)
	obstacle.add_to_group("obstacles")
	obstacle.z_index = -10
	obstacle.scale = GlobalValues.scale
	obstacle.position = pos * GlobalValues.tile_size
	obstacle_positions.append(pos)


func _on_player_ate() -> void:
	score += 1
	score_label.text = str(score)
	update_difficulty()
	call_deferred("spawn_food")


func _on_player_lost() -> void:
	get_tree().paused = true
	game_over_score_label.text = str(score)
	game_over_panel.show()
	print("Gameover! Final Score: {0}".format([score]))


func advance_player() -> void:
	$GridOffset/Player.update()
	# advance all body parts
	get_tree().call_group("body_parts", "pre_advance")
	get_tree().call_group("body_parts", "advance")


func update_difficulty() -> void:
	if score > final_advance_time_score:
		return
	var time: float = (
		final_advance_time
		+ difficulty_formula_multiplier * pow(score - final_advance_time_score, 2)
	)
	$AdvanceTimer.wait_time = time
	GlobalValues.advance_time = time
	print("advance time: %s" % $AdvanceTimer.wait_time)


func spawn_food() -> void:
	var available_positions: Array = all_positions.duplicate()
	var occupied_positions: Array = []

	occupied_positions += obstacle_positions  # add obstacle positions
	occupied_positions += $GridOffset/Player.get_occupied_positions()  # add player positions
	for food in $GridOffset/Food.get_children():  # add food positions
		occupied_positions += [food.position / GlobalValues.tile_size]

	for occupied_position in occupied_positions:
		var occupied_index = available_positions.find(occupied_position)
		if occupied_index != -1:
			available_positions.remove(occupied_index)

	if available_positions.size() == 0:
		print("A winner is you!")
		return

	var spawn_position: Vector2 = available_positions[randi() % available_positions.size()]
	var food: Area2D = Food.instance()
	$GridOffset/Food.add_child(food)
	food.add_to_group("food")
	food.scale = GlobalValues.scale
	food.position = spawn_position * GlobalValues.tile_size


func _on_RetryButton_pressed():
	var _err = get_tree().reload_current_scene()
	get_tree().paused = false


func _on_MainMenuButton_pressed():
	var _err = get_tree().change_scene("res://main_menu/MainMenu.tscn")
	get_tree().paused = false
