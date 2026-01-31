class_name Level
extends Node2D


var enemy_spawn_points: Array[EnemySpawnPoint] = []

var player: Player

var enemies: Array[Enemy] = []


func _enter_tree() -> void:
	G.level = self


func _exit_tree() -> void:
	if G.level == self:
		G.level = null


func _ready() -> void:
	pass


func start() -> void:
	reset()


func reset() -> void:
	player.destroy()

	for enemy in enemies:
		enemy.destroy()
	enemies.clear()

	spawn_player()

	for spawn_point in enemy_spawn_points:
		spawn_enemy(spawn_point)


func register_enemy_spawn_point(point: EnemySpawnPoint) -> void:
	enemy_spawn_points.append(point)


func spawn_player() -> void:
	swap_mask(%PlayerSpawnPoint.global_position, Player.MaskType.NONE)
	# TODO: Have the player start out lying down in bed.


func swap_mask(p_position: Vector2, mask_type: Player.MaskType) -> void:
	if is_instance_valid(player):
		player.destroy()
	player = G.settings.get_player_for_mask_type(mask_type).instantiate()
	player.global_position = p_position
	%Players.add_child(player)



func spawn_enemy(spawn_point: EnemySpawnPoint) -> void:
	var enemy: Enemy = G.settings.get_scene_for_enemy_type(spawn_point.enemy_type).instantiate()
	enemy.spawn_point = spawn_point
	enemy.global_position = spawn_point.global_position
	enemies.append(enemy)
	%Enemies.add_child(enemy)
