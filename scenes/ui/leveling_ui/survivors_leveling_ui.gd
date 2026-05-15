extends Control

@export var IMPROVEMENT_CHOICE_SCENE: PackedScene

@onready var upgrades_container: Control = $Panel/Upgrades
@onready var improvement_pool: ImprovementPool = $ImprovementPool

var _player_ref: SurvivorsPlayer = null

signal player_chose_improvement()

func _ready() -> void:
	visible = false
	mouse_filter = Control.MOUSE_FILTER_IGNORE


func open_for_player(player: SurvivorsPlayer) -> void:
	_player_ref = player
	get_tree().paused = true
	_show_levelup_panel()


func _show_levelup_panel() -> void:
	visible = true
	_populate_improvement_choices()


func _populate_improvement_choices() -> void:
	for child in upgrades_container.get_children():
		child.queue_free()

	if _player_ref == null:
		return

	var choices: Array[Resource] = improvement_pool.get_random_choices(_player_ref)
	if choices.is_empty():
		_close_panel()
		_resume_game()
		return

	for imp in choices:
		var choice: ImprovementChoice = IMPROVEMENT_CHOICE_SCENE.instantiate()
		choice.data = imp
		upgrades_container.add_child(choice)
		choice.chosen.connect(_on_improvement_chosen)


func _on_improvement_chosen(imp: Resource) -> void:
	if _player_ref != null and imp != null:
		if imp is WeaponResource:
			_player_ref.add_weapon(imp)
		elif imp is SurvivorsUpgrade:
			_player_ref.add_upgrade(imp)

	_close_panel()
	player_chose_improvement.emit()

	if not visible:
		_resume_game()


func _close_panel() -> void:
	visible = false


func _resume_game() -> void:
	get_tree().paused = false
	_player_ref = null
