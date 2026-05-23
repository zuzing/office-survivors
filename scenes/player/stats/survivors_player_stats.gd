extends Resource
class_name SurvivorStats

@export_group("Core")
@export var base_hp: float = 100.0
@export_storage var hp: float = base_hp

@export_group("Shield")
@export var base_shield: float = 100.0
@export_storage var shield: float = base_shield
@export var shield_recharge_delay: float = 3.0
@export var shield_recharge_rate: float = 20.0

@export_group("Progression")
@export var level: int = 1
@export var current_exp: float = 0.0
@export var exp_to_next_level: float = 1000.0

@export_group("Miscellaneous")
@export var move_speed: float = 1.0          # base move speed factor (can be 1.0)
@export var exp_pickup_radius: float = 64.0  # base pickup radius, if you want it stored here

var score: int = 0
