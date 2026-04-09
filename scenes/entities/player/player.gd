extends CharacterBody2D
class_name Player
## Player character controller handling movement and interactions.
##
## This script handles:
## - Movement based on input actions (WASD or arrows).
## - Flipping the character sprite based on direction.
##
## Interface:
## - Moves via "move_left", "move_right", "move_up", "move_down" actions.

@export var movement_speed : float = 500
var character_direction : Vector2
var last_facing_direction : Vector2 = Vector2.RIGHT
@onready var sprite = $sprite

func _physics_process(_delta: float) -> void:
	character_direction.x = Input.get_axis("move_left", "move_right")
	character_direction.y = Input.get_axis("move_up", "move_down")
	character_direction = character_direction.normalized()
	
	if character_direction != Vector2.ZERO:
		last_facing_direction = character_direction
	#flip sprite
	if character_direction.x > 0: $sprite.flip_h = true
	elif character_direction.x < 0: $sprite.flip_h = false
	
	if character_direction:
		velocity = character_direction * movement_speed
	else:
		velocity = velocity.move_toward(Vector2.ZERO, movement_speed)
		
	move_and_slide()
