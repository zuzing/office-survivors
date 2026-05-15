extends Area2D
class_name XPShardPickup

enum XPShard { LOW, MEDIUM, HIGH }

@export var shard_type: XPShard = XPShard.LOW

var shard_values := {
	XPShard.LOW: 10,
	XPShard.MEDIUM: 25,
	XPShard.HIGH: 50
}

@onready var sprite := $Sprite2D

func _ready():
	_update_visual()
	
func _update_visual():
	match shard_type:
		XPShard.LOW:
			sprite.modulate = Color(0.4, 0.6, 1.0)
		XPShard.MEDIUM:
			sprite.modulate = Color(0.3, 1.0, 0.3)
		XPShard.HIGH:
			sprite.modulate = Color(1.0, 0.385, 0.674, 1.0)
