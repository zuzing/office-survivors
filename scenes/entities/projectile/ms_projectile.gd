extends CharacterBody2D


@export var damage := 8
@export var speed := 300.0
@export var lifetime := 3.0

var direction := Vector2.RIGHT

func _ready() -> void:
	set_meta("projectile", true)

func _physics_process(delta: float) -> void:
	velocity = direction * speed
	var collision_info = move_and_collide(velocity * delta)
	
	lifetime -= delta
	if lifetime <= 0:
		queue_free()
		return
	
	if collision_info:
		var collider = collision_info.get_collider()
		if collider and collider.has_method("take_damage"):
			collider.take_damage(damage)
			queue_free()
			return
		
		queue_free()

func set_direction(dir: Vector2) -> void:
	direction = dir.normalized()

func set_damage(dmg: int) -> void:
	damage = dmg

func set_velocity_data(vel: Vector2) -> void:
	direction = vel.normalized()
	speed = vel.length()
