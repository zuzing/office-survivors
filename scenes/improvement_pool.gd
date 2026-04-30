extends Node
class_name ImprovementPool

var improvements: Array[Resource] = []

const NUM_OF_IMPROVEMENTS_IN_A_CHOICE: int = 3
const PATH_UPGRADES: String = "res://scenes/resources/upgrades/"
const PATH_WEAPONS: String = "res://scenes/resources/weapons/"

func _ready() -> void:
	improvements.clear()
	
	_load_resources_from_dir(PATH_UPGRADES)
	_load_resources_from_dir(PATH_WEAPONS)
	
	# CRITICAL: Duplicate the array content on startup.
	var distinct_instances: Array[Resource] = []
	for imp in improvements:
		distinct_instances.append(imp.duplicate())
	improvements = distinct_instances


func _load_resources_from_dir(path: String) -> void:
	var dir = DirAccess.open(path)
	if not dir:
		push_error("ImprovementPool: Could not open directory: " + path)
		return
		
	var file_names = dir.get_files() 
	
	for file_name in file_names:
		var clean_name = file_name.replace(".remap", "")
		
		if clean_name.ends_with(".tres") or clean_name.ends_with(".res"):
			var full_path = path + clean_name
			var resource = load(full_path)
			if resource:
				improvements.append(resource)

func get_random_choices(player: SurvivorsPlayer) -> Array[Resource]:
	var available := _get_available_improvements(player)
	
	if available.is_empty():
		return []

	available.shuffle()
	
	return available.slice(0, min(NUM_OF_IMPROVEMENTS_IN_A_CHOICE, available.size()))


func _get_available_improvements(player: SurvivorsPlayer) -> Array[Resource]:
	var result: Array[Resource] = []

	for imp in improvements:
		if _is_improvement_possible(player, imp):
			result.append(imp)

	return result


func _is_improvement_possible(player: SurvivorsPlayer, imp: Resource) -> bool:
	if imp is SurvivorsUpgrade:
		return _is_upgrade_possible(player, imp)

	if imp is WeaponResource:
		return _is_weapon_possible(player, imp)

	return true


func _is_upgrade_possible(player: SurvivorsPlayer, upgrade: SurvivorsUpgrade) -> bool:
	if player.has_an_upgrade(upgrade):
		return not upgrade.is_max_level()

	if player.upgrade_slots_are_full():
		return false

	return true


func _is_weapon_possible(player: SurvivorsPlayer, weapon: WeaponResource) -> bool:
	if player.has_a_weapon(weapon): 
		return not weapon.is_max_level()
		
	if player.weapon_slots_are_full():
		return false

	return true
