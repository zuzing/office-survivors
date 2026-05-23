extends Control

const MAIN_MENU_SCENE := "res://scenes/ui/main_menu/main_menu.tscn"

func _ready() -> void:
	process_mode = Node.PROCESS_MODE_ALWAYS
	hide()

func _input(event: InputEvent) -> void:
	if event.is_action_pressed("ui_cancel"):
		if visible:
			_on_resume_pressed()
		elif not get_tree().paused:
			_show_pause()

func _show_pause() -> void:
	show()
	get_tree().paused = true

func _on_resume_pressed() -> void:
	hide()
	get_tree().paused = false

func _on_main_menu_pressed() -> void:
	get_tree().paused = false
	get_tree().change_scene_to_file(MAIN_MENU_SCENE)
