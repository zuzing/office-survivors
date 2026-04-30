@abstract
class_name MSEnemy

extends CharacterBody2D

@export var resource: EnemyResource

@onready var nav_agent := $NavigationAgent2D
@onready var collision_shape := $CollisionShape2D
@onready var timer := $Timer

const XPShardScene := preload("res://scenes/entities/shard/xp_shard.tscn")

var can_attack := true
var player

var current_health: int 

func _ready() -> void:
	await get_tree().process_frame
	add_to_group("enemies")
	player = get_tree().get_first_node_in_group("player")
	nav_agent.set_navigation_map(get_world_2d().navigation_map)
	nav_agent.avoidance_enabled = true
	nav_agent.radius = collision_shape.shape.radius + 2
	timer.timeout.connect(_on_timer_timeout)
	_set_sprite()
	_set_collisions()
	if resource:
		current_health = resource.health
	else:
		push_error("Brak przypisanego EnemyResource dla przeciwnika!")
		current_health = 100


func _physics_process(delta: float) -> void:
	_update_behavior(delta)

@abstract
func _update_behavior(_delta: float)

func make_path() -> void:
	nav_agent.target_position = player.global_position

func take_damage(damage: int) -> void:
	$HitFlashAnimation.play("hit_flash")
	current_health  -= damage
	if current_health  <= 0:
		_die()

func _die() -> void:
	_drop_xp_shard()
	queue_free()
	
func _drop_xp_shard() -> void:
	var shard = XPShardScene.instantiate()
	
	shard.shard_type = resource.exp_reward
	
	shard.global_position = global_position
	
	get_tree().current_scene.call_deferred("add_child", shard)

func _on_timer_timeout() -> void:
	make_path()


func _set_sprite() -> void:
	if resource.sprite_texture:
		$Sprite2D.texture = resource.sprite_texture
		$Sprite2D.scale = resource.sprite_scale

func _set_collisions() -> void:
	if resource.enemy_size_radius:
		$CollisionShape2D.shape.radius = resource.enemy_size_radius
