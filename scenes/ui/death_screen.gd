extends Control

@export var level_label: Label
@export var message_label: Label
@export var stats_label: Label
@export var weapons_container: Container

func _ready() -> void:
	process_mode = Node.PROCESS_MODE_ALWAYS
	hide()
	mouse_filter = Control.MOUSE_FILTER_IGNORE

	var player_node = get_tree().get_first_node_in_group("player")

	if player_node:
		if player_node.has_signal("player_died"):
			player_node.player_died.connect(_on_player_died)
		else:
			printerr("BŁĄD: Znaleziono węzeł w grupie 'player', ale nie ma on sygnału 'player_died'!")
	else:
		printerr("BŁĄD: DeathScreen nie znalazł gracza! Upewnij się, że SurvivorsPlayer jest w grupie 'player'.")

func _on_player_died(player: SurvivorsPlayer) -> void:
	_setup_ui(player)
	show()
	get_tree().paused = true

func _setup_ui(player: SurvivorsPlayer) -> void:
	if level_label:
		level_label.text = "Osiągnięto poziom: " + str(player.stats.level)

	if message_label:
		message_label.text = _get_flavor_text(player.stats.level)

	if stats_label:
		var txt = "Statystyki:\n"
		txt += "HP: %d | Tarcza: %d\n" % [player.get_effective_max_hp(), player.get_effective_max_shield()]
		txt += "Siła: +%d%%\n" % ((player.multipliers.damage_multiplier - 1.0) * 100)
		txt += "Wynik: %d pkt" % player.stats.score
		stats_label.text = txt

	_populate_weapons(player.weapon_slots)


func _get_flavor_text(level: int) -> String:
	if level < 3:
		return "To był tylko pierwszy poniedziałek... Kawa w końcu zacznie działać, głowa do góry."
	elif level < 10:
		return "Coś tam ogarniasz w te klawisze."
	elif level < 20:
		return "Walczyłeś dzielnie, ale seria spotkań była silniejsza."
	else:
		return "Legenda biura! Ale nawet legendy czasem zapominają dodać załącznika."

func _populate_weapons(weapons: Array[WeaponResource]) -> void:
	for child in weapons_container.get_children():
		child.queue_free()

	for weapon in weapons:
		if weapon == null: continue

		var icon_rect = TextureRect.new()
		icon_rect.texture = weapon.icon
		icon_rect.expand_mode = TextureRect.EXPAND_IGNORE_SIZE
		icon_rect.custom_minimum_size = Vector2(64, 64)
		icon_rect.stretch_mode = TextureRect.STRETCH_KEEP_ASPECT_CENTERED
		icon_rect.tooltip_text = weapon.name
		weapons_container.add_child(icon_rect)


func _on_retry_pressed() -> void:
	get_tree().paused = false
	get_tree().reload_current_scene()

func _on_return_pressed() -> void:
	get_tree().paused = false
	get_tree().change_scene_to_file("res://scenes/ui/main_menu/main_menu.tscn")
