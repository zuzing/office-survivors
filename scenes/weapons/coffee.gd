extends Weapon

@export var glitch_zone_scene: PackedScene

func _attack() -> void:
	if not weapon_resource.projectile_scene: return

	var count = final_projectile_count

	for i in range(count):
		var proj = weapon_resource.projectile_scene.instantiate()
		proj.global_position = global_position

		var random_offset = Vector2(randf_range(-150, 150), randf_range(-150, 150))
		proj.target_pos = global_position + random_offset

		proj.glitch_scene = glitch_zone_scene
		proj.damage = final_damage
		proj.duration = final_duration
		proj.area_size = final_size

		get_tree().current_scene.add_child(proj)
