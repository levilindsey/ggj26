class_name Bullet
extends Node2D


const _BULLET_DAMAGE := 10
const _BULLET_SPEED := 200.0
const _BULLET_MAX_DISTANCE := 175.0


var is_moving_right := true
var start_position := Vector2.INF


func _physics_process(delta: float) -> void:
	var direction_sign := (
		1 if
		is_moving_right else
		-1
	)
	position.x += (_BULLET_SPEED * direction_sign) * delta
	if absf(global_position.x - start_position.x) > _BULLET_MAX_DISTANCE:
		G.level.remove_bullet(self)


func _on_area_2d_body_entered(body: Node2D) -> void:
	if not body is Enemy:
		return
	var enemy := body as Enemy
	enemy.take_damage(_BULLET_DAMAGE)
	G.level.remove_bullet(self)
