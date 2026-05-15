extends Area2D

var damage: float = 0.0
var duration: float = 3.0

func _ready() -> void:
	get_tree().create_timer(duration).timeout.connect(queue_free)

	var tick_timer = Timer.new()
	tick_timer.wait_time = 0.5
	tick_timer.autostart = true
	tick_timer.timeout.connect(_on_tick)
	add_child(tick_timer)

func _on_tick() -> void:
	var bodies = get_overlapping_bodies()
	for body in bodies:
		if body.is_in_group("enemies") and body.has_method("take_damage"):
			body.take_damage(damage)
