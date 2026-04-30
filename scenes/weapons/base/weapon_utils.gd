extends Node
class_name WeaponUtils

static func get_nearest_enemy(from_position: Vector2, max_range: float = INF) -> Node2D:
	var enemies = Engine.get_main_loop().root.get_tree().get_nodes_in_group("enemies")
	var nearest = null
	var min_dist = INF
	
	for enemy in enemies:
		if enemy and enemy.is_inside_tree():
			var dist = from_position.distance_to(enemy.global_position)
			if dist < min_dist and dist <= max_range:
				min_dist = dist
				nearest = enemy
	
	return nearest
