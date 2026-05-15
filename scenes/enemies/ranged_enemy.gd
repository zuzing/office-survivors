extends MSEnemy
class_name MSEnemyRanged

@onready var projectile_spawn_point := $ProjectileSpawnPoint

var attacking := false
var preferred_distance := 250.0

func _ready() -> void:
	super._ready()
	if resource:
		preferred_distance = resource.attack_range * 0.8

	if not projectile_spawn_point:
		projectile_spawn_point = Node2D.new()
		projectile_spawn_point.name = "ProjectileSpawnPoint"
		projectile_spawn_point.position = Vector2(0, 0)
		add_child(projectile_spawn_point)

	if not resource.projectile_scene:
		var default_path = "res://scenes/entities/projectile/enemy_paper_projectile.tscn"
		if ResourceLoader.exists(default_path):
			resource.projectile_scene = load(default_path)

func _update_behavior(delta: float) -> void:
	if not player:
		return

	var distance = global_position.distance_to(player.global_position)

	if distance > resource.attack_range:
		_move_toward_player(delta)
	elif distance < resource.min_attack_range:
		_move_away_from_player(delta)
	else:
		_maintain_distance(delta)
		if not attacking and can_attack:
			_start_attack()

func _move_toward_player(_delta: float) -> void:
	var dir: Vector2
	if not nav_agent.is_navigation_finished():
		var next_point = nav_agent.get_next_path_position()
		if next_point == Vector2.ZERO or next_point.distance_to(global_position) < 1.0:
			dir = (player.global_position - global_position).normalized()
		else:
			dir = (next_point - global_position).normalized()
	else:
		dir = (player.global_position - global_position).normalized()

	velocity = dir * resource.speed
	move_and_slide()

func _move_away_from_player(_delta: float) -> void:
	var dir = (global_position - player.global_position).normalized()
	velocity = dir * resource.speed
	move_and_slide()

func _maintain_distance(delta: float) -> void:
	var distance = global_position.distance_to(player.global_position)
	if distance < preferred_distance - 20:
		_move_away_from_player(delta)
	elif distance > preferred_distance + 20:
		_move_toward_player(delta)
	else:
		velocity = Vector2.ZERO
		move_and_slide()

func _start_attack() -> void:
	attacking = true
	can_attack = false
	velocity = Vector2.ZERO
	move_and_slide()

	if not player:
		attacking = false
		can_attack = true
		return

	_shoot_projectile((player.global_position - global_position).normalized())

	await get_tree().create_timer(resource.attack_cooldown).timeout
	attacking = false
	can_attack = true

func _shoot_projectile(direction: Vector2) -> void:
	if not resource.projectile_scene:
		return

	var projectile = resource.projectile_scene.instantiate()
	get_tree().current_scene.add_child(projectile)

	var spawn_pos = projectile_spawn_point.global_position if projectile_spawn_point else global_position
	projectile.global_position = spawn_pos

	if projectile.has_method("set_direction"):
		projectile.set_direction(direction)
	elif "direction" in projectile:
		projectile.direction = direction.normalized()
		if "speed" in projectile:
			projectile.speed = resource.projectile_speed

	if projectile.has_method("set_damage"):
		projectile.set_damage(resource.attack_damage)
	elif "damage" in projectile:
		projectile.damage = resource.attack_damage
