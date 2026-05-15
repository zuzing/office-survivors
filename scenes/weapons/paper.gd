extends Weapon

@export var time_between_shots: float = 0.1

func _attack():
	if not weapon_resource.projectile_scene:
		push_error("[Weapon] projectile scene not found")
		return

	var count = final_projectile_count
	var current_delay = time_between_shots / player_stats.attack_speed_multiplier

	for i in range(count):
		if not is_instance_valid(self):
			return

		var target = WeaponUtils.get_nearest_enemy(global_position)
		var fire_direction: Vector2 = Vector2.RIGHT

		if target:
			fire_direction = (target.global_position - global_position).normalized()
		else:
			if player and "last_facing_direction" in player and player.last_facing_direction != Vector2.ZERO:
				fire_direction = player.last_facing_direction
			elif player and player.velocity != Vector2.ZERO:
				fire_direction = player.velocity.normalized()
			else:
				fire_direction = Vector2.RIGHT

		_spawn_single_projectile(fire_direction)

		if i < count - 1:
			await get_tree().create_timer(current_delay).timeout

func _spawn_single_projectile(direction: Vector2) -> void:
	var proj = weapon_resource.projectile_scene.instantiate()
	proj.global_position = global_position

	if proj.has_method("set_direction"):
		proj.set_direction(direction)
	elif "direction" in proj:
		proj.direction = direction

	if "speed" in proj:
		proj.speed = final_projectile_speed

	if "damage" in proj:
		proj.damage = final_damage

	proj.scale = Vector2.ONE * final_size

	get_tree().current_scene.add_child(proj)
