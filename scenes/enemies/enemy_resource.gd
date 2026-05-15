extends Resource
class_name EnemyResource

enum XPShard { LOW, MEDIUM, HIGH }

@export var health := 100
@export var exp_reward: XPShard = XPShard.LOW
@export var attack_cooldown := 1.0

@export var contact_damage := 10

@export var speed: = 200.0

@export var attack_range := 350.0
@export var min_attack_range := 120.0
@export var attack_damage := 10
@export var projectile_speed := 350.0
@export var projectile_scene: PackedScene

@export var sprite_texture: Texture2D
@export var sprite_scale: Vector2 = Vector2.ONE

@export var hitbox_radius: float
@export var enemy_size_radius: float
