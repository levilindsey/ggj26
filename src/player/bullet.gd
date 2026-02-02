class_name Bullet
extends Node2D


const _BULLET_DAMAGE := 50
const _BULLET_SPEED := 200.0


var is_moving_right := true


func _physics_process(delta: float) -> void:
	var direction_sign := (
		1 if
		is_moving_right else
		-1
	)
	position.x += (_BULLET_SPEED * direction_sign) * delta


func _on_area_2d_body_entered(body: Node2D) -> void:
	if not body is Enemy:
		return
	var enemy := body as Enemy
	enemy.take_damage(_BULLET_DAMAGE)
	G.level.remove_bullet(self)
