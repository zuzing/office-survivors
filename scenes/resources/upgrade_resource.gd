extends Resource
class_name SurvivorsUpgrade

enum TargetProperty {
	MAX_HP,
	MAX_SHIELD,
	ARMOR,
	EXP_GAIN,
	DAMAGE,
	ATTACK_SPEED,
	ATTACK_RANGE,
	MOVE_SPEED,
	EXP_PICKUP
}

const PROPERTY_NAMES := {
	TargetProperty.MAX_HP:          &"max_hp_multiplier",
	TargetProperty.MAX_SHIELD:      &"max_shield_multiplier",
	TargetProperty.ARMOR:           &"armor",
	TargetProperty.EXP_GAIN:        &"exp_gain_multiplier",
	TargetProperty.DAMAGE:          &"damage_multiplier",
	TargetProperty.ATTACK_SPEED:    &"attack_speed_multiplier",
	TargetProperty.ATTACK_RANGE:    &"attack_range_multiplier",
	TargetProperty.MOVE_SPEED:      &"move_speed_multiplier",
	TargetProperty.EXP_PICKUP:      &"exp_pickup_multiplier",
}

@export var name: String = ""
@export var icon: Texture2D
@export_multiline var description: String = ""

@export var target_property: TargetProperty = TargetProperty.DAMAGE

@export var level_modifiers: Array[float] = []

@export_storage var level: int = 0

func max_level() -> int:
	return level_modifiers.size()
	
func is_max_level() -> bool:
	return level >= max_level()

func get_property_name() -> StringName:
	return PROPERTY_NAMES[target_property]
