class_name Hud
extends PanelContainer


var mask_cards: Array[HudMaskCard] = []


func _enter_tree() -> void:
	G.hud = self


func _ready() -> void:
	# Wait for G.settings to be assigned.
	await get_tree().process_frame

	self.visible = G.settings.show_hud

	for card in %MasksContainer.get_children():
		mask_cards.append(card)

	_clear_mask_cards()


func update_visibility() -> void:
	match G.screens.current_screen:
		ScreensMain.ScreenType.MAIN_MENU, \
		ScreensMain.ScreenType.GAME_OVER, \
		ScreensMain.ScreenType.WIN, \
		ScreensMain.ScreenType.PAUSE:
			pass
		ScreensMain.ScreenType.GAME:
			pass
		_:
			G.utils.ensure(false)


func update_health() -> void:
	%HealthBar.value = (
		G.level.player.health_progress if
		is_instance_valid(G.level.player) else
		0.0
	)


func update_masks() -> void:
	if not is_instance_valid(G.level.player):
		_clear_mask_cards()
	elif G.level.player.current_masks.size() <= 1:
		_clear_mask_cards()
	else:
		for card in mask_cards:
			card.is_collected = G.level.player.current_masks.has(card.mask_type)
			#var is_equipped = G.level.player.mask_type == card.mask_type
			var card_index_in_player_collection := (
				G.level.player.current_masks.find(card.mask_type)
			)
			card.is_selected = (
				G.level.player.selected_mask_index ==
				card_index_in_player_collection
			)

	# Update heart vs shield icon.
	var is_strong_defense := (
		is_instance_valid(G.level.player) and G.level.player.is_strong_defense
	)
	%HeartIcon.visible = not is_strong_defense
	%ShieldIcon.visible = is_strong_defense


func _clear_mask_cards() -> void:
	for card in mask_cards:
		card.is_collected = false
		card.is_selected = false
