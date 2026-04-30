extends Control
							#ColorRect/Statistics/HBoxContainer/Label
@onready var max_hp_value = $ColorRect/Statistics/MaxHpRow/MaxHpValue
@onready var max_shield_value = $ColorRect/Statistics/MaxShieldRow/MaxShieldValue
#@onready var armor_value = $ColorRect/Statistics/ArmorRow/ArmorValue
@onready var exp_gain_multiplier_value = $ColorRect/Statistics/ExpGainMultiplierRow/ExpGainMultiplierValue
@onready var damage_multiplier_value = $ColorRect/Statistics/DamageMultiplierRow/DamageMultiplierValue
@onready var attack_speed_multiplier_value = $ColorRect/Statistics/AttackSpeedMultiplierRow/AttackSpeedMultiplierValue
@onready var attack_range_multiplier_value = $ColorRect/Statistics/AttackRangeMultiplierRow/AttackRangeMultiplierValue
@onready var move_speed_multiplier_value = $ColorRect/Statistics/MoveSpeedMultiplierRow/MoveSpeedMultiplierValue
@onready var exp_pickup_multiplier_value = $ColorRect/Statistics/ExpPickupMultiplierRow/ExpPickupMultiplierValue

# Maks. Zdrowie
# Maks. Tarcza
# Pancerz
# Mnożnik EXP
# Mnożnik Obrażeń
# Szybkość Ataku
# Zasięg Ataku
# Szybkość Ruchu
# Zasięg zbierania

func _safe_set(label: Node, value: String, label_name: String) -> void:
	if label:
		label.text = value
	else:
		push_warning("UI ERROR: '%s' node is missing in survivor_player_statistics_ui scene!" % label_name)

#
func update_stats(player: Player) -> void:
	_safe_set(max_hp_value, str(player.get_effective_max_hp()), "MaxHpValue")
	_safe_set(max_shield_value, str(player.get_effective_max_shield()), "MaxShieldValue")
	#_safe_set(armor_value, str(stats.armor), "ArmorValue")
	_safe_set(exp_gain_multiplier_value, str(player.multipliers.exp_gain_multiplier), "ExpGainMultiplierValue")
	_safe_set(damage_multiplier_value, str(player.multipliers.damage_multiplier), "DamageMultiplierValue")
	_safe_set(attack_speed_multiplier_value, str(player.multipliers.attack_speed_multiplier), "AttackSpeedMultiplierValue")
	_safe_set(attack_range_multiplier_value, str(player.multipliers.attack_range_multiplier), "AttackRangeMultiplierValue")
	_safe_set(move_speed_multiplier_value, str(player.multipliers.move_speed_multiplier), "MoveSpeedMultiplierValue")
	_safe_set(exp_pickup_multiplier_value, str(player.multipliers.exp_pickup_multiplier), "ExpPickupMultiplierValue")
