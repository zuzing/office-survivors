extends Node
class_name SurvivorsGameManager

@export var initial_budget: int = 10
@export var budget_increase_step: int = 2
@export var time_between_waves: float = 6
@export var enemy_list: Array[SurvivorsEnemyResource]

var player: CharacterBody2D
var timer: Timer
var budget: int
var enemy_counts: Array[int] = [] # how much of each enemy to spawn
var wave_number: int = 0

func _ready() -> void:
	# init timer
	timer = Timer.new()
	timer.one_shot = false
	timer.wait_time = time_between_waves
	timer.timeout.connect(_on_timer_timeout)
	timer.autostart = true
	self.add_child(timer)
	
	# init player
	player = get_tree().get_first_node_in_group("player")
	
	# init budget
	budget = initial_budget

	# order list from most expensive to cheapest
	enemy_list = _merge_sort_enemy_list(enemy_list)
	
	# initialize enemy_counts
	for i in range(enemy_list.size()):
		enemy_counts.append(0)

func _clear_enemies_to_spawn():
	for i in range(enemy_counts.size()):
		enemy_counts[i] = 0
	
func _buy_enemies():
	var remaining := budget
	var affordable := enemy_list.filter(func(e): return e.cost <= remaining)

	while affordable.size() > 0:
		var pick: SurvivorsEnemyResource = affordable[randi() % affordable.size()]
		enemy_counts[enemy_list.find(pick)] += 1
		remaining -= pick.cost
		affordable = enemy_list.filter(func(e): return e.cost <= remaining)

	_spawn_enemies()
			
	
func _create_enemies():
	var is_custom = false
	
	if not is_custom:
		_buy_enemies()
	
func _spawn(scene, distance, resource):
	var enemy_instance: Node2D = scene.instantiate()
	var random_pos = randf() * 2 * PI
	var enemy_x = player.global_position.x + distance * sin(random_pos)
	var enemy_y = player.global_position.y + distance * cos(random_pos)
	enemy_instance.global_position = Vector2(enemy_x, enemy_y)
	enemy_instance.resource = resource
	add_child(enemy_instance)
	
	
	
func _spawn_enemies():
	for enemy in range(enemy_list.size()):
		if enemy_counts[enemy] == 0:
			continue
		for i in range(enemy_counts[enemy]):
			_spawn(enemy_list[enemy].enemy, enemy_list[enemy].spawn_distance_from_player, enemy_list[enemy].enemy_resource)

	
func _increase_budget():
	wave_number += 1
	budget = initial_budget + budget_increase_step * wave_number
	
func _on_timer_timeout():
	_create_enemies()
	_clear_enemies_to_spawn()
	_increase_budget()
	
func _merge_sort_enemy_list(arr: Array[SurvivorsEnemyResource]) -> Array:
	if arr.size() <= 1:
		return arr.duplicate()

	@warning_ignore("integer_division")
	var mid = arr.size() / 2
	var left = _merge_sort_enemy_list(arr.slice(0, mid))
	var right = _merge_sort_enemy_list(arr.slice(mid, arr.size()))

	return _merge(left, right)

func _merge(left: Array, right: Array) -> Array:
	var result: Array[SurvivorsEnemyResource] = []
	var left_index = 0
	var right_index = 0

	while left_index < left.size() and right_index < right.size():
		var should_swap = left[left_index].cost > right[right_index].cost

		if should_swap:
			result.append(left[left_index])
			left_index += 1
		else:
			result.append(right[right_index])
			right_index += 1

	# Add remaining elements
	while left_index < left.size():
		result.append(left[left_index])
		left_index += 1

	while right_index < right.size():
		result.append(right[right_index])
		right_index += 1

	return result
