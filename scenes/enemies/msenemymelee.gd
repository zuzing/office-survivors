extends MSEnemy
class_name MSEnemyMelee

@onready var hitbox: Area2D = $Hitbox

func _ready() -> void:
	super._ready()
	if hitbox:
		hitbox.collision_mask = 0 
	
		hitbox.set_collision_mask_value(2, true)
		
		hitbox.collision_layer = 0
		
	else:
		push_error("Błąd: Ten przeciwnik nie ma przypisanego Hitboxa!")
	_set_hitbox_size()

func _update_behavior(_delta: float) -> void:
	if not player:
		return
	if nav_agent.is_navigation_finished():
		velocity = Vector2.ZERO
		move_and_slide()
		return

	var next_position = nav_agent.get_next_path_position()
	var direction = (next_position - global_position).normalized()

	velocity = direction * resource.speed
	move_and_slide()
	
	if can_attack:
		_check_for_player_contact()

func _check_for_player_contact() -> void:
	var overlapping_bodies = hitbox.get_overlapping_bodies()
	
	for body in overlapping_bodies:
		if body == player:
			_attack_player()
			break 

func _attack_player() -> void:
	if not player or not player.has_method("take_damage"):
		return
	
	player.take_damage(resource.contact_damage)
	
	can_attack = false
	var t = get_tree().create_timer(resource.attack_cooldown)
	
	t.timeout.connect(func(): 
		if is_instance_valid(self):
			can_attack = true
	)
	
func _set_hitbox_size() -> void:
	if resource.hitbox_radius:
		$Hitbox/CollisionShape2D.shape.radius = resource.hitbox_radius
	
