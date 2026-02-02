class_name Ghost
extends Enemy


@export var attack_vertical_speed := 100.0
@export var attack_horizontal_speed := 100.0

@export var wind_up_duration_sec := 0.6


func _ready() -> void:
	super._ready()


func _update_behavior_velocity() -> void:
	if current_behavior == Behavior.ATTACK and is_instance_valid(G.level.player):
		current_behavior_target = G.level.player.global_position

	var is_moving := _is_behavior_movement(current_behavior)
	if not is_moving and current_behavior != Behavior.ATTACK:
		velocity.x = 0.0
		return

	var direction_sign := _get_direction_sign_to_target(
		current_behavior_target)

	# Face the player.
	if direction_sign < 0:
		face_left()
	else:
		face_right()

	if (current_behavior == Behavior.CHASE and
		absf(G.level.player.global_position.x - global_position.x) <
		_APPROACH_DISTANCE_THRESHOLD
	):
		# We're already close enough.
		velocity.x = 0.0
		return

	# Set the speed.
	var is_slow := _is_behavior_a_slow_walk(current_behavior)
	var speed := wander_speed if is_slow else chase_speed
	velocity.x = speed * direction_sign

	if absf(current_behavior_target.y - global_position.y) < 2.0:
		velocity.y = 0.0
	else:
		var vertical_direction_sign := (
			-1 if current_behavior_target.y < global_position.y else 1
		)
		velocity.y = speed * vertical_direction_sign



func _process_movement(_delta: float) -> void:
	_update_behavior_velocity()
	position.x += velocity.x * _delta
	position.y += velocity.y * _delta



func _trigger_attack() -> void:
	# Do nothing. Just keep floating toward.
	pass
	#await get_tree().create_timer(wind_up_duration_sec).timeout
#
	## Lunge toward the player.
#
	#var direction_sign := _get_direction_sign_to_target(
		#G.level.player.global_position)
	#velocity.x = attack_horizontal_speed * direction_sign
#
	#if absf(G.level.player.global_position.y - global_position.y) < 2.0:
		#velocity.y = 0.0
	#else:
		#var vertical_direction_sign := (
			#-1 if G.level.player.global_position.y < global_position.y else 1
		#)
		#velocity.y = attack_vertical_speed * vertical_direction_sign
