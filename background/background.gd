extends Control

onready var hider_left: Sprite = $HiderLeft
onready var hider_right: Sprite = $HiderRight
onready var hider_top: Sprite = $HiderTop
onready var hider_bottom: Sprite = $HiderBottom


func position_hider(grid_offset: Vector2, grid_size: Vector2) -> void:
	hider_left.position.x = grid_offset.x - 0.5 * GlobalValues.tile_size
	hider_left.position.y = 0

	hider_right.position.x = grid_offset.x + (grid_size.x - 0.5) * GlobalValues.tile_size
	hider_right.position.y = 0

	hider_top.position.y = grid_offset.y - 0.5 * GlobalValues.tile_size
	hider_top.position.x = 0

	hider_bottom.position.y = grid_offset.y + (grid_size.y - 0.5) * GlobalValues.tile_size
	hider_bottom.position.x = 0
