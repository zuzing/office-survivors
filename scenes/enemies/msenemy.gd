@abstract
class_name MSEnemy

extends CharacterBody2D

@export var resource: EnemyResource

@onready var nav_agent := $NavigationAgent2D
@onready var collision_shape := $CollisionShape2D

const XPShardScene := preload("res://scenes/entities/shard/xp_shard.tscn")
const PATH_UPDATE_INTERVAL := 0.15

var can_attack := true
var player

var current_health: int
var _path_timer := 0.0

func _ready() -> void:
	await get_tree().process_frame
	add_to_group("enemies")
	player = get_tree().get_first_node_in_group("player")
	nav_agent.avoidance_enabled = false
	_set_sprite()
	_set_collisions()
	if resource:
		current_health = resource.health
	else:
		push_error("Brak przypisanego EnemyResource dla przeciwnika!")
		current_health = 100
	make_path()


func _physics_process(delta: float) -> void:
	_path_timer += delta
	if _path_timer >= PATH_UPDATE_INTERVAL:
		_path_timer = 0.0
		make_path()
	_update_behavior(delta)

@abstract
func _update_behavior(_delta: float)

func make_path() -> void:
	if player:
		nav_agent.target_position = player.global_position

func take_damage(damage: int) -> void:
	$HitFlashAnimation.play("hit_flash")
	current_health -= damage
	if current_health <= 0:
		_die()

const SCORE_BY_SHARD := {
	EnemyResource.XPShard.LOW: 10,
	EnemyResource.XPShard.MEDIUM: 25,
	EnemyResource.XPShard.HIGH: 50
}

func _die() -> void:
	if player and player.has_method("add_kill"):
		player.add_kill(SCORE_BY_SHARD.get(resource.exp_reward, 10))
	_drop_xp_shard()
	queue_free()

func _drop_xp_shard() -> void:
	var shard = XPShardScene.instantiate()
	shard.shard_type = resource.exp_reward
	shard.global_position = global_position
	get_tree().current_scene.call_deferred("add_child", shard)


func _set_sprite() -> void:
	if resource.sprite_texture:
		$Sprite2D.texture = resource.sprite_texture
		$Sprite2D.scale = resource.sprite_scale

func _set_collisions() -> void:
	if resource.enemy_size_radius:
		$CollisionShape2D.shape.radius = resource.enemy_size_radius
