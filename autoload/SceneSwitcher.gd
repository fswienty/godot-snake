extends Node

var current_scene: Node = null
var level_json_path: String = ""


func _ready() -> void:
	var root = get_tree().get_root()
	current_scene = root.get_child(root.get_child_count() - 1)
	print("current scene: %s" % current_scene.name)


# func load_scene(scene: PackedScene) -> void:
# 	call_deferred("_deferred_switch_to_scene", scene.resource_path)


func load_scene_from_path(scene_path: String) -> void:
	call_deferred("_deferred_switch_to_scene", scene_path)


func _deferred_switch_to_scene(path) -> void:
	for child in TemporaryNodes.get_children():  # remove everything from TemporaryNodes
		child.free()
	var _err = get_tree().change_scene(path)
#	print(err)
#	current_scene.free()  # It is now safe to remove the current scene
#	var s = ResourceLoader.load(path)  # Load the new scene
#	current_scene = s.instance()  # Instance the new scene
#	get_tree().get_root().add_child(current_scene)  # Add it to the active scene, as child of root
#	get_tree().set_current_scene(current_scene)  # Optionally, to make it compatible with the SceneTree.change_scene() API
#	print("current scene: %s" %current_scene.name)
