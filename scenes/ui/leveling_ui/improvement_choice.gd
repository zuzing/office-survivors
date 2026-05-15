extends Button
class_name ImprovementChoice

signal chosen(imp: Resource)

@onready var icon_rect: TextureRect = $TextureRect
@onready var level_label: Label = %Level
@onready var name_label: Label = $Name
@onready var desc_label: Label = $Description

@export var data: Resource:
	set(value):
		data = value
		if is_inside_tree():
			_apply_data()


func _ready() -> void:
	if data:
		_apply_data()

	self.pressed.connect(_on_pressed)


func _apply_data() -> void:
	if data == null:
		return

	if data is WeaponResource or data is SurvivorsUpgrade:
		name_label.text = data.name
		level_label.text = str(data.level+1)
		desc_label.text = data.description
		icon_rect.texture = data.icon
	else:
		push_warning("ImprovementChoice received unexpected type: %s" % data)


func _on_pressed() -> void:
	chosen.emit(data)
