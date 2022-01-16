extends Node

const game_scene_path: String = "res://game_scene/GameScene.tscn"
onready var level_select_panel: Panel = $VBoxContainer/VBoxContainer/MainMenu/LevelSelectPanel
onready var level_item_list: ItemList = $VBoxContainer/VBoxContainer/MainMenu/LevelSelectPanel/ItemList
var level_files: Array
const levels_folder: String = "res://levels"


func _ready() -> void:
	populate_level_list()
	print("tile size: %s" % GlobalValues.tile_size)


func populate_level_list() -> void:
	# get list of files in levels directory
	var dir = Directory.new()
	dir.open(levels_folder)
	dir.list_dir_begin(true, true)
	while true:
		var file = dir.get_next()
		if file == "":
			break
		level_files.append(file)
	dir.list_dir_end()

	# load all jsons
	for level_file in level_files:
		var file = File.new()
		file.open(levels_folder + "/" + level_file, File.READ)
		# parse json file
		var p: JSONParseResult = JSON.parse(file.get_as_text())
		# validation
		if p.error:
			print("error loading %s" % level_file)
			continue
		level_item_list.add_item(p.result.name)


func _on_LevelSelect_pressed() -> void:
	level_select_panel.show()
	var initial_level_index: int = 0
	level_item_list.select(initial_level_index)
	_on_ItemList_item_selected(initial_level_index)


func _on_CustomLevel_pressed() -> void:
	var fd: FileDialog = $PopupLayer/FileDialog
	fd.popup()


func _on_QuitButton_pressed() -> void:
	get_tree().quit()


func _on_ItemList_close_pressed() -> void:
	level_select_panel.hide()


func _on_ItemList_start_pressed() -> void:
	SceneSwitcher.load_scene_from_path(game_scene_path)


func _on_ItemList_item_selected(index: int) -> void:
	SceneSwitcher.level_json_path = levels_folder + "/" + level_files[index]


func _on_FileDialog_file_selected(path):
	SceneSwitcher.level_json_path = path
	SceneSwitcher.load_scene_from_path(game_scene_path)
