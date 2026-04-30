extends Control

@export var level: Label
@export var health_bar: ProgressBar
@export var shield_bar: ProgressBar
@export var exp_bar: ProgressBar

func update_stats(player: Player) -> void:
	var stats: SurvivorStats = player.stats

	if level:
		level.text = str(stats.level)

	if health_bar:
		health_bar.max_value = player.get_effective_max_hp()
		health_bar.value = stats.hp

	if shield_bar:
		shield_bar.max_value = player.get_effective_max_shield()
		shield_bar.value = stats.shield

	if exp_bar:
		exp_bar.max_value = stats.exp_to_next_level
		exp_bar.value = stats.current_exp
