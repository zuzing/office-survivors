@abstract
class_name Weapon
extends Marker2D

@export var weapon_resource: WeaponResource

var player: Player
var player_stats: SurvivorsMultipliers

@onready var timer = $Timer

var final_damage: float
var final_cooldown: float
var final_projectile_count: int
var final_projectile_speed: float
var final_size: float
var final_duration: float

@abstract
func _attack()

func _ready():
	player = get_tree().get_first_node_in_group("player")
	timer.timeout.connect(_on_timer_timeout)
	
	player.multipliers_changed.connect(update_stats)
	update_stats()

func _on_timer_timeout() -> void:
	_attack()
	
func update_stats() -> void:
	if not player or not weapon_resource:
		return
	get_player_stats()
	final_damage = weapon_resource.current_damage * player_stats.damage_multiplier
	
	if player_stats.attack_speed_multiplier > 0:
		final_cooldown = weapon_resource.current_cooldown / player_stats.attack_speed_multiplier
	else:
		final_cooldown = weapon_resource.current_cooldown
	
	final_projectile_count = weapon_resource.current_projectile_count + player_stats.player_projectile_count
	
	final_projectile_speed = weapon_resource.current_projectile_speed
	
	final_size = weapon_resource.current_size * player_stats.attack_range_multiplier
	
	final_duration = weapon_resource.current_duration
	
	if timer:
		timer.wait_time = max(0.05, final_cooldown)
		if timer.is_stopped(): timer.start()
		
	scale = Vector2.ONE * final_size


func get_player_stats() -> void:
	player_stats = player.multipliers
