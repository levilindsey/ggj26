class_name Hud
extends PanelContainer


var mask_cards: Array[HudMaskCard] = []


func _enter_tree() -> void:
	G.hud = self


func _ready() -> void:
	# Hide the title, so we can fade it in.
	%Title.modulate.a = 0.0

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


func fade_in_title() -> void:
	fade_in(%Title)
	fade_out(%GameState)


func fade_out_title() -> void:
	fade_in(%GameState)
	fade_out(%Title)


func fade_in(node: CanvasItem) -> void:
	node.modulate.a = 0.0
	var tween := create_tween()
	tween.tween_property(
		node,
		"modulate:a",
		1.0,
		0.3)


func fade_out(node: CanvasItem) -> void:
	node.modulate.a = 1.0
	var tween := create_tween()
	tween.tween_property(
		node,
		"modulate:a",
		0.0,
		0.3)


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
		var cards_by_type := {}
		for card in mask_cards:
			cards_by_type[card.mask_type] = card

		# Re-order.
		for i in range(G.level.player.current_masks.size()):
			var mask_type := G.level.player.current_masks[i]
			var card: HudMaskCard = cards_by_type[mask_type]
			%MasksContainer.move_child(card, i)

		# Mark collected and selected.
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
