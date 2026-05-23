extends Node

const GAME_SCENE := "res://scenes/levels/temp_map/temp_level.tscn"

func _on_start_pressed() -> void:
	get_tree().change_scene_to_file(GAME_SCENE)

func _on_quit_pressed() -> void:
	get_tree().quit()
