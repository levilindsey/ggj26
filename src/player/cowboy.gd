class_name Cowboy
extends Player


func _ready() -> void:
	super._ready()


func _process(_delta: float) -> void:
	super._process(_delta)


func _physics_process(_delta: float) -> void:
	super._physics_process(_delta)


func _trigger_ability() -> void:
	G.print("Pew")

	var bullet_offset: Vector2 = %BulletSpawnPositionRight.position
	if not surface_state.is_facing_right:
		bullet_offset.x *= -1

	G.level.add_bullet(
		global_position + bullet_offset,
		surface_state.is_facing_right)
