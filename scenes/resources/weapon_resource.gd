extends Resource
class_name WeaponResource

enum WeaponStat {
	DAMAGE,
	COOLDOWN,
	PROJECTILE_COUNT,
	PROJECTILE_SPEED,
	SIZE,
	DURATION
}

const STAT_VAR_NAMES := {
	WeaponStat.DAMAGE:           &"current_damage",
	WeaponStat.COOLDOWN:         &"current_cooldown",
	WeaponStat.PROJECTILE_COUNT: &"current_projectile_count",
	WeaponStat.PROJECTILE_SPEED: &"current_projectile_speed",
	WeaponStat.SIZE:             &"current_size",
	WeaponStat.DURATION:         &"current_duration",
}

const INSPECTOR_KEYS := {
	"damage":           WeaponStat.DAMAGE,
	"cooldown":         WeaponStat.COOLDOWN,
	"projectile_count": WeaponStat.PROJECTILE_COUNT,
	"projectile_speed": WeaponStat.PROJECTILE_SPEED,
	"size":             WeaponStat.SIZE,
	"duration":         WeaponStat.DURATION,
}

@export var name: String
@export var icon: Texture2D
@export_multiline var description: String = ""

@export_group("Visuals & Scene")
@export var weapon_scene: PackedScene
@export var projectile_scene: PackedScene

# --- Level 1 stats ---
@export_group("Base Stats")
@export var base_damage: float = 10.0
@export var base_cooldown: float = 1.0
@export var base_projectile_count: int = 1
@export var base_projectile_speed: float = 500.0
@export var base_size: float = 1.0
@export var base_duration: float = 1.0

@export_group("Leveling")
# Example Dict in Inspector: {"damage": 5.0, "cooldown": -0.1}
@export var level_upgrades: Array[Dictionary] = []

@export_storage var level: int = 0

# Internal current stats
var current_damage: float
var current_cooldown: float
var current_projectile_count: int
var current_projectile_speed: float
var current_size: float
var current_duration: float

func initialize_stats() -> void:
	current_damage = base_damage
	current_cooldown = base_cooldown
	current_projectile_count = base_projectile_count
	current_projectile_speed = base_projectile_speed
	current_size = base_size
	current_duration = base_duration
	
func max_level() -> int:
	return 1 + level_upgrades.size()
	
func is_max_level() -> bool:
	return self.level >= max_level()
	
func level_up() -> void:
	level += 1
	
	# Level 1 is base, no upgrades applied
	if level == 1:
		return
	
	# Array is 0-indexed, so Level 2 = index 0
	var upgrade_index = level - 2
	
	if upgrade_index >= 0 and upgrade_index < level_upgrades.size():
		var changes = level_upgrades[upgrade_index]
		_apply_single_upgrade(changes)

func _apply_single_upgrade(changes: Dictionary) -> void:
	for key in changes.keys():
		
		if INSPECTOR_KEYS.has(key):
			var stat_enum: WeaponStat = INSPECTOR_KEYS[key]
			var variable_name: StringName = STAT_VAR_NAMES[stat_enum]
			var modifier_value = changes[key]
			
			var current_val = get(variable_name)
			
			if typeof(current_val) == typeof(modifier_value):
				set(variable_name, current_val + modifier_value)
			else:
				push_warning("Type mismatch in weapon upgrade for key: " + key)
		else:
			push_warning("Unknown upgrade key used in WeaponResource: " + str(key))
