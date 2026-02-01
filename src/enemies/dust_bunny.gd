class_name DustBunny
extends Enemy


## Only relevant if bounces_when_attacking is true.
@export var attack_bounce_vertical_boost := 80.0
@export var attack_bounce_horizontal_boost := 200.0

@export var wind_up_duration_sec := 0.6


func _trigger_attack() -> void:
	await get_tree().create_timer(wind_up_duration_sec).timeout

	# Lunge toward the player.
	var direction_sign := _get_direction_sign_to_target(
		G.level.player.global_position)
	velocity.x = attack_bounce_horizontal_boost * direction_sign
	velocity.y = attack_bounce_vertical_boost
