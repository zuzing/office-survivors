extends Resource
class_name SurvivorsMultipliers

@export_group("DefenseMultipliers")
@export var max_hp_multiplier: float = 1.0
@export var max_shield_multiplier: float = 1.0
@export_range(0.0, 1.0, 0.01) var armor: float = 0.0    # 0.0–1.0 -> % damage reduction

@export_group("ProgressionMultipliers")
@export var exp_gain_multiplier: float = 1.0

@export_group("WeaponMultipliers")
@export var damage_multiplier: float = 1.0
@export var attack_speed_multiplier: float = 1.0
@export var attack_range_multiplier: float = 1.0
@export var player_projectile_count: int = 1

@export_group("MiscellaneousMultipliers")
@export var move_speed_multiplier: float = 1.0
@export var exp_pickup_multiplier: float = 1.0  # affects pickup radius
