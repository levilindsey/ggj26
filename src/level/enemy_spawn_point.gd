class_name EnemySpawnPoint
extends Node2D


@export var enemy_type := Enemy.Type.DUST_BUNNY


func _ready() -> void:
	G.level.register_enemy_spawn_point(self)
