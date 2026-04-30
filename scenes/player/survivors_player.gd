extends Player
class_name SurvivorsPlayer

const NUM_WEAPON_SLOTS: int = 3
const NUM_UPGRADE_SLOTS: int = 3

@export_group("Stats")
@export var base_stats: SurvivorStats
@export var base_multipliers: SurvivorsMultipliers

var stats: SurvivorStats
var multipliers: SurvivorsMultipliers

var time_since_last_damage: float = 0.0

# --- QUEUE LOGIC ---
var pending_upgrades: int = 0
var is_choosing_upgrade: bool = false
# -------------------

@export_group("Weapons & Upgrades")
@export var weapon_slots: Array[WeaponResource] = []
@export var upgrade_slots: Array[SurvivorsUpgrade] = []

@onready var _exp_pickup_shape: CollisionShape2D = $ExpPickupArea/CollisionShape2D
@onready var player_ui: Control = $CanvasLayer/SurvivorsPlayerUI
@onready var stats_ui: Control = $CanvasLayer/SurvivorsPlayerStatistics
@onready var leveling_ui = $CanvasLayer/SurvivorsLevelingUI

var weapon_nodes: Dictionary = {}

signal multipliers_changed()
signal player_died(player_instance: SurvivorsPlayer)

# ======================
#  LIFECYCLE
# ======================

func _ready() -> void:

	if stats_ui == null:
		push_warning("stats_ui is NULL! Check path: $CanvasLayer/SurvivorsPlayerStatistics")
	if player_ui == null:
		push_warning("player_ui is NULL! Check path: $CanvasLayer/SurvivorsPlayerUI")

	leveling_ui.player_chose_improvement.connect(_on_player_chose_improvement)

	stats = base_stats.duplicate(true) if base_stats else SurvivorStats.new()
	multipliers = base_multipliers.duplicate(true) if base_multipliers else SurvivorsMultipliers.new()

	stats.hp = get_effective_max_hp()
	stats.shield = get_effective_max_shield()

	_update_exp_pickup_radius()
	
	for weapon in weapon_slots:
		if weapon != null:
			weapon.initialize_stats()
			_instantiate_weapon_scene(weapon)
			_level_up_weapon(weapon)
	
	multipliers_changed.emit()	
	_update_ui()


func _physics_process(delta: float) -> void:
	_handle_movement(delta)
	_handle_shield_recharge(delta)


# ======================
#  INPUT & MOVEMENT
# ======================

func _handle_movement(_delta: float) -> void:
	character_direction.x = Input.get_axis("move_left", "move_right")
	character_direction.y = Input.get_axis("move_up", "move_down")
	character_direction = character_direction.normalized()

	if character_direction != Vector2.ZERO:
		last_facing_direction = character_direction

	if character_direction.x > 0:
		$sprite.flip_h = true
	elif character_direction.x < 0:
		$sprite.flip_h = false

	if character_direction:
		var effective_speed: float = movement_speed * multipliers.move_speed_multiplier
		velocity = character_direction * effective_speed
	else:
		velocity = velocity.move_toward(Vector2.ZERO, movement_speed)

	move_and_slide()


# ======================
#  UI
# ======================

func _update_ui() -> void:
	if player_ui:
		player_ui.update_stats(self)
	if stats_ui:
		stats_ui.update_stats(self)

# ======================
#  EFFECTIVE VALUES
# ======================

func get_effective_max_hp() -> float:
	return stats.base_hp * multipliers.max_hp_multiplier


func get_effective_max_shield() -> float:
	return stats.base_shield * multipliers.max_shield_multiplier


# ======================
#  HP
# ======================

func take_damage(amount: float) -> void:
	time_since_last_damage = 0.0
	var final_damage: float = _apply_armor(amount)
	final_damage = _apply_shield(final_damage)

	if final_damage > 0.0:
		_decrement_hp(final_damage)

	_update_ui()

	if stats.hp <= 0.0:
		die()


func _apply_armor(amount: float) -> float:
	if multipliers == null:
		return amount

	var reduction: float = clamp(multipliers.armor, 0.0, 1.0)
	return amount * (1.0 - reduction)


func _apply_shield(damage: float) -> float:
	if stats == null or stats.shield <= 0.0:
		return damage

	var shield_damage: float = min(damage, stats.shield)
	stats.shield -= shield_damage
	return damage - shield_damage


func _decrement_hp(amount: float) -> void:
	if stats == null:
		return

	stats.hp = max(stats.hp - amount, 0.0)


func _heal(amount: float) -> void:
	stats.hp = min(stats.hp + amount, get_effective_max_hp())
	_update_ui()


# ======================
#  PROGRESSION / EXP
# ======================

func add_exp(raw_amount: float) -> void:
	var amount: float = raw_amount * multipliers.exp_gain_multiplier
	stats.current_exp += amount

	while stats.current_exp >= stats.exp_to_next_level:
		stats.current_exp -= stats.exp_to_next_level
		stats.level += 1
		
		_update_max_hp_on_level_up()
		_update_exp_to_next_level()
		
		pending_upgrades += 1

	_update_ui()
	
	_process_upgrade_queue()


func _process_upgrade_queue() -> void:
	if pending_upgrades > 0 and not is_choosing_upgrade:
		pending_upgrades -= 1
		is_choosing_upgrade = true
		leveling_ui.open_for_player(self)


func _on_player_chose_improvement():
	stats.hp = get_effective_max_hp()
	
	multipliers_changed.emit()
	_update_ui()
	
	is_choosing_upgrade = false
	_process_upgrade_queue()


const EXP_TO_NEXT_LEVEL_MULTIPLIERS := [1.25, 1.3, 1.35, 1.4, 1.45, 1.5]

func _update_exp_to_next_level() -> void:
	var exp_mult_index: int = stats.level - 2
	if exp_mult_index >= 0:
		exp_mult_index = min(exp_mult_index, EXP_TO_NEXT_LEVEL_MULTIPLIERS.size() - 1)
		var exp_mult: float = EXP_TO_NEXT_LEVEL_MULTIPLIERS[exp_mult_index]
		stats.exp_to_next_level *= exp_mult


const LEVEL_UP_MAX_HP_MULTIPLIERS := [0.2, 0.15, 0.1]

func _update_max_hp_on_level_up() -> void:
	# level 1 -> no bonus
	# level 2 -> use index 0
	# level 3 -> use index 1
	# level 4+ -> keep using last value
	var hp_mult_index: int = stats.level - 2
	if hp_mult_index < 0:
		return

	hp_mult_index = min(hp_mult_index, LEVEL_UP_MAX_HP_MULTIPLIERS.size() - 1)
	var hp_mult: float = LEVEL_UP_MAX_HP_MULTIPLIERS[hp_mult_index]

	multipliers.max_hp_multiplier += hp_mult
	stats.hp += get_effective_max_hp()

# ======================
#  DEATH
# ======================

func die() -> void:
	player_died.emit(self)


# ======================
#  SHIELD RECHARGE
# ======================

func _handle_shield_recharge(delta: float) -> void:
	time_since_last_damage += delta
	_recharge_shield(delta)


func _recharge_shield(delta: float) -> void:
	if stats == null:
		return

	if stats.shield >= get_effective_max_shield():
		return

	if time_since_last_damage < stats.shield_recharge_delay:
		return

	var old_shield: float = stats.shield
	stats.shield = min(
		stats.shield + stats.shield_recharge_rate * delta,
		get_effective_max_shield()
	)

	if stats.shield != old_shield:
		_update_ui()


# ======================
#  WEAPON HELPERS
# ======================

func get_damage_multiplier() -> float:
	return multipliers.damage_multiplier


func get_attack_speed_multiplier() -> float:
	return multipliers.attack_speed_multiplier


func get_attack_range_multiplier() -> float:
	return multipliers.attack_range_multiplier


# ======================
#  EXP PICKUP LOGIC
# ======================

func _update_exp_pickup_radius() -> void:
	if _exp_pickup_shape == null or stats == null:
		return

	var circle: CircleShape2D = _exp_pickup_shape.shape
	if circle:
		var radius: float = stats.exp_pickup_radius * multipliers.exp_pickup_multiplier
		circle.radius = radius


func _on_ExpPickupArea_area_entered(area: Area2D) -> void:
	if area is XPShardPickup:
		var shard: XPShardPickup = area as XPShardPickup
		_pick_up_shard(shard)


func _pick_up_shard(shard: XPShardPickup) -> void:
	var gained_exp: float = shard.shard_values[shard.shard_type]
	add_exp(gained_exp)
	shard.queue_free()

# ======================
#  EQUIPMENT & UPGRADES
# ======================

func get_equipment() -> Array[WeaponResource]:
	return weapon_slots


func get_upgrades() -> Array[SurvivorsUpgrade]:
	return upgrade_slots

func add_weapon(weapon: WeaponResource) -> void:
	if not self.has_a_weapon(weapon):
		weapon.initialize_stats()
		weapon_slots.append(weapon)
		_instantiate_weapon_scene(weapon)
	_level_up_weapon(weapon)

func _instantiate_weapon_scene(weapon: WeaponResource) -> void:
	if not weapon.weapon_scene:
		push_error("WeaponResource has no scene (weapon_scene)!")
		return
	var weapon_instance = weapon.weapon_scene.instantiate()
	weapon_instance.weapon_resource = weapon
	add_child(weapon_instance)
	weapon_nodes[weapon] = weapon_instance
	weapon_instance.update_stats()

func add_upgrade(upgrade: SurvivorsUpgrade) -> void:
	if upgrade == null:
		return
		
	if not self.has_an_upgrade(upgrade):
		upgrade_slots.append(upgrade)
	
	_level_up_upgrade(upgrade) # upgrades start at level 0

	_apply_upgrade_effect(upgrade, upgrade.level)
	_update_exp_pickup_radius()


func has_a_weapon(weapon: WeaponResource) -> bool:
	return weapon_slots.any(func(w): return w.name == weapon.name)


func has_an_upgrade(upgrade: SurvivorsUpgrade) -> bool:
	return upgrade_slots.any(func(u): return u.name == upgrade.name)


func _level_up_upgrade(upgrade: SurvivorsUpgrade) -> void:
	if upgrade.is_max_level():
		return

	upgrade.level += 1
	_apply_upgrade_effect(upgrade, upgrade.level)
	_update_exp_pickup_radius()
	_update_ui()

func _level_up_weapon(weapon_instance: WeaponResource) -> void:
	if weapon_instance.level >= weapon_instance.max_level(): return
	weapon_instance.level_up()
	if weapon_nodes.has(weapon_instance):
		var node = weapon_nodes[weapon_instance]
		if node.has_method("update_stats"):
			node.update_stats()
	_update_ui()

func weapon_slots_are_full() -> bool:
	return weapon_slots.size() >= NUM_WEAPON_SLOTS


func upgrade_slots_are_full() -> bool:
	return upgrade_slots.size() >= NUM_UPGRADE_SLOTS


# ======================
#  UPGRADE EFFECT HELPER
# ======================

func _apply_upgrade_effect(upgrade: SurvivorsUpgrade, level: int) -> void:
	if level <= 0 or level > upgrade.max_level():
		return

	var prop_name: StringName = upgrade.get_property_name()
	var modifiers: Array[float] = upgrade.level_modifiers
	var modifier: float = modifiers[level - 1]
	var current_value = multipliers.get(prop_name)
	if typeof(current_value) == TYPE_NIL:
		push_warning("Multipliers does not have property '%s' for upgrade '%s'" % [prop_name, upgrade.name])
		return

	multipliers.set(prop_name, current_value + modifier)
