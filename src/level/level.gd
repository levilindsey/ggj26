class_name Level
extends Node2D


const _RESET_READY_TO_START_GAME_DELAY_SEC := 0.3
const _GAME_OVER_READY_TO_RESET_DELAY_SEC := 0.3

const _PLAYER_CAMERA_OFFSET := Vector2(0, -10)

var enemy_spawn_points: Array[EnemySpawnPoint] = []
var mask_pickups: Array[MaskPickup] = []

var player: Player

var enemies: Array[Enemy] = []

var bullets: Array[Bullet] = []
var ice_spikes: Array[IceSpike] = []

var has_started := false
var has_finished := false
var has_won := false
var has_cookied := false
var is_ready_for_input_to_activate_next_game := false


func _enter_tree() -> void:
	G.level = self


func _exit_tree() -> void:
	if G.level == self:
		G.level = null


func _ready() -> void:
	reset()


func reset() -> void:
	if is_instance_valid(player):
		player.destroy()

	for enemy in enemies:
		enemy.destroy()
	enemies.clear()

	for spawn_point in enemy_spawn_points:
		spawn_enemy(spawn_point)

	for pickup in mask_pickups:
		pickup.enabled = true

	has_started = false
	has_finished = false
	has_won = false
	has_cookied = false
	is_ready_for_input_to_activate_next_game = false

	%SleepingGirl.visible = true
	G.hud.fade_in_title()
	G.hud.fade_in_controls()

	G.hud.update_health()
	G.hud.update_masks()

	# Swap the color palette.
	G.palette_swapper.swap_index = Player.get_palette_swap_index_for_mask(
		Player.MaskType.NONE)

	await get_tree().create_timer(_RESET_READY_TO_START_GAME_DELAY_SEC).timeout

	G.print("Ready to receive input", ScaffolderLog.CATEGORY_GAME_STATE)

	is_ready_for_input_to_activate_next_game = true


func start_game() -> void:
	G.print("Starting game", ScaffolderLog.CATEGORY_GAME_STATE)

	has_started = true
	is_ready_for_input_to_activate_next_game = false
	spawn_player()
	G.hud.fade_out_title()
	G.hud.fade_out_controls()


func game_over() -> void:
	G.print("Game over", ScaffolderLog.CATEGORY_GAME_STATE)
	has_finished = true
	await get_tree().create_timer(_GAME_OVER_READY_TO_RESET_DELAY_SEC).timeout
	G.print("Resetting for next game", ScaffolderLog.CATEGORY_GAME_STATE)
	reset()


func win() -> void:
	G.hud.fade_in_credits()
	has_won = true
	swap_mask(Player.MaskType.NONE)


func _input(event: InputEvent) -> void:
	if not is_ready_for_input_to_activate_next_game:
		return

	if (
		event.is_action_pressed("move_up") or
		event.is_action_pressed("move_down") or
		event.is_action_pressed("move_left") or
		event.is_action_pressed("move_right") or
		event.is_action_pressed("jump") or
		event.is_action_pressed("ability") or
		event.is_action_pressed("mask") or
		event.is_action_pressed("scroll_left") or
		event.is_action_pressed("scroll_right")
	):
		start_game()


func _physics_process(_delta: float) -> void:
	if is_instance_valid(player):
		%Camera2D.global_position = player.global_position + _PLAYER_CAMERA_OFFSET
	else:
		%Camera2D.global_position = %PlayerSpawnPoint.global_position + _PLAYER_CAMERA_OFFSET


func register_enemy_spawn_point(point: EnemySpawnPoint) -> void:
	enemy_spawn_points.append(point)


func spawn_player() -> void:
	%SleepingGirl.visible = false
	swap_mask(Player.MaskType.NONE)
	player.play_sound("spawn")

	# Optionally start with all masks.
	if G.settings.start_with_all_masks:
		player.current_masks.clear()
		for type in player.MaskType.values():
			player.current_masks.append(type)

	G.hud.update_health()
	G.hud.update_masks()


func swap_mask(mask_type: Player.MaskType) -> void:
	var previous_player := player

	var previous_position: Vector2 = (
		previous_player.global_position if
		is_instance_valid(previous_player) else
		%PlayerSpawnPoint.global_position
	)

	player = G.settings.get_player_for_mask_type(mask_type).instantiate()

	if is_instance_valid(previous_player):
		player.copy(previous_player)

	if is_instance_valid(previous_player):
		previous_player.destroy()
	%Players.call_deferred("add_child", player)
	player.global_position = previous_position
	player.call_deferred("set_global_position", previous_position)

	# Swap the color palette.
	G.palette_swapper.swap_index = Player.get_palette_swap_index_for_mask(
		player.mask_type)

	G.hud.update_masks()

	G.audio.fade_to_mask_theme(mask_type)


func spawn_enemy(spawn_point: EnemySpawnPoint) -> void:
	var enemy: Enemy = G.settings.get_scene_for_enemy_type(spawn_point.enemy_type).instantiate()
	enemy.spawn_point = spawn_point
	enemy.global_position = spawn_point.global_position + Vector2.UP * 0.5
	enemy.debug = spawn_point.debug
	enemies.append(enemy)
	%Enemies.add_child(enemy)


func remove_enemy(enemy: Enemy) -> void:
	enemies.erase(enemy)
	enemy.queue_free()


func add_bullet(p_position: Vector2, p_is_moving_right: bool) -> void:
	var bullet: Bullet = G.settings.bullet_scene.instantiate()
	%Projectiles.add_child(bullet)
	bullet.global_position = p_position
	bullet.start_position = p_position
	bullet.is_moving_right = p_is_moving_right
	bullets.append(bullet)


func remove_bullet(bullet: Bullet) -> void:
	bullets.erase(bullet)
	bullet.queue_free()


func add_ice_spike(p_position: Vector2) -> void:
	var ice_spike: IceSpike = G.settings.ice_spike_scene.instantiate()
	%Projectiles.add_child(ice_spike)
	ice_spike.global_position = p_position
	ice_spikes.append(ice_spike)


func remove_ice_spike(ice_spike: IceSpike) -> void:
	ice_spikes.erase(ice_spike)
	ice_spike.queue_free()
