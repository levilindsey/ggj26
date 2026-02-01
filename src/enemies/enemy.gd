class_name Enemy
extends CharacterBody2D


enum Type {
	DUST_BUNNY,
	RAT,
	GHOST,
	NIGHTMARE,
	SPIDER,
}

enum Behavior {
	NONE,
	WANDER_LEFT,
	WANDER_RIGHT,
	RETURN,
	WAKE_UP,
	SLEEP,
	CHASE,
	ATTACK,
	REPOSITION_FOR_ATTACK,
	IDLE_PAUSE,
	PRE_CHASE_PAUSE,
	ATTACK_PAUSE,
	PLAYER_DIED_PAUSE,
	STOP_AT_EDGE_FOR_WANDER,
	STOP_AT_EDGE_FOR_CHASE,
}

enum IdleType {
	WANDER,
	SLEEP,
}


const _BODY_CONTACT_DAMAGE := 20
const _LOSE_DETECTION_DELAY_SEC := 3.5
const _APPROACH_DISTANCE_THRESHOLD := 2.0
const _IDLE_PAUSE_DURATION_MIN_SEC := 0.5
const _IDLE_PAUSE_DURATION_MAX_SEC := 1.0
const _WANDER_STEP_DISTANCE_MIN := 32.0
const _WANDER_STEP_DISTANCE_MAX := 128.0
const _EDGE_DETECTION_RAY_CAST_LENGTH := 50.0


@export var type := Type.DUST_BUNNY

@export var idle_type := IdleType.WANDER

## This is only relevant for IdleType.SLEEP.
@export var wake_up_duration_sec := 0.0

@export var attack_duration_sec := 0.5

@export var pre_chase_pause_duration_sec := 0.2
@export var attack_pause_duration_sec := 1.0
@export var player_died_pause_duration_sec := 1.0

@export var animated_sprite: AnimatedSprite2D
@export var collision_shape: CollisionShape2D
@export var damage_player_area: Area2D
@export var detection_range: Area2D
@export var attack_max_range_area: Area2D
@export var attack_min_range_area: Area2D

@export var chase_speed := 100.0
@export var wander_speed := 50.0

@export var bounces_when_walking := false

## Only relevant if bounces_when_walking is true.
@export var walk_bounce_boost := 60.0

## Only relevant if bounces_when_walking is true.
@export var chase_bounce_boost := 70.0

@export var faces_right_by_default := false

@export var max_health := 100

@export var defense := 1.0

@onready var current_health := max_health

var spawn_point: EnemySpawnPoint

var edge_detection_ray_cast: RayCast2D

var current_behavior := Behavior.NONE
var previous_behavior := Behavior.NONE
var current_behavior_end_time_sec := 0.0
var previous_behavior_end_time_sec := 0.0
var current_behavior_start_time_sec := 0.0
var previous_behavior_start_time_sec := 0.0
var current_behavior_target := Vector2.INF
var previous_behavior_target := Vector2.INF

var is_player_in_body_contact_damage_range := false
var is_player_in_detection_range := false
var is_player_in_attack_max_range := false
var is_player_in_attack_min_range := false
var last_detection_time_sec := 0.0

var half_size := Vector2.INF
var damage_player_radius := 0.0
var detection_range_radius := 0.0
var attack_max_range_radius := 0.0
var attack_min_range_radius := 0.0

var just_switched_behaviors := false

var was_on_floor := false
var has_ever_been_on_floor := false
var just_jumped := false

var is_in_air: bool:
	get:
		return not is_on_floor()

var just_entered_air: bool:
	get:
		return was_on_floor and not is_on_floor()

var just_landed: bool:
	get:
		return not was_on_floor and is_on_floor()

var is_dead: bool:
	get:
		return current_health == 0


func _get_direction_sign_to_target(target: Vector2) -> int:
	return -1 if target.x < global_position.x else 1


func _is_behavior_movement(p_behavior: Behavior) -> bool:
	match p_behavior:
		Behavior.WANDER_LEFT, \
		Behavior.WANDER_RIGHT, \
		Behavior.RETURN, \
		Behavior.CHASE, \
		Behavior.REPOSITION_FOR_ATTACK:
			return true
		Behavior.NONE, \
		Behavior.WAKE_UP, \
		Behavior.SLEEP, \
		Behavior.ATTACK, \
		Behavior.IDLE_PAUSE, \
		Behavior.PRE_CHASE_PAUSE, \
		Behavior.ATTACK_PAUSE, \
		Behavior.PLAYER_DIED_PAUSE, \
		Behavior.STOP_AT_EDGE_FOR_WANDER, \
		Behavior.STOP_AT_EDGE_FOR_CHASE:
			return false
		_:
			G.fatal()
			return false


func _is_behavior_a_slow_walk(p_behavior: Behavior) -> bool:
	match p_behavior:
		Behavior.WANDER_LEFT, \
		Behavior.WANDER_RIGHT, \
		Behavior.RETURN:
			return true
		Behavior.NONE, \
		Behavior.WAKE_UP, \
		Behavior.SLEEP, \
		Behavior.CHASE, \
		Behavior.ATTACK, \
		Behavior.REPOSITION_FOR_ATTACK, \
		Behavior.IDLE_PAUSE, \
		Behavior.PRE_CHASE_PAUSE, \
		Behavior.ATTACK_PAUSE, \
		Behavior.PLAYER_DIED_PAUSE, \
		Behavior.STOP_AT_EDGE_FOR_WANDER, \
		Behavior.STOP_AT_EDGE_FOR_CHASE:
			return false
		_:
			G.fatal()
			return false


func _does_behavior_require_player(p_behavior: Behavior) -> bool:
	match p_behavior:
		Behavior.NONE, \
		Behavior.WANDER_LEFT, \
		Behavior.WANDER_RIGHT, \
		Behavior.RETURN, \
		Behavior.SLEEP, \
		Behavior.IDLE_PAUSE, \
		Behavior.PLAYER_DIED_PAUSE, \
		Behavior.STOP_AT_EDGE_FOR_WANDER:
			return false
		Behavior.WAKE_UP, \
		Behavior.CHASE, \
		Behavior.ATTACK, \
		Behavior.REPOSITION_FOR_ATTACK, \
		Behavior.PRE_CHASE_PAUSE, \
		Behavior.ATTACK_PAUSE, \
		Behavior.STOP_AT_EDGE_FOR_CHASE:
			return true
		_:
			G.fatal()
			return false


func _ready() -> void:
	G.check(is_instance_valid(animated_sprite))
	G.check(is_instance_valid(collision_shape))
	G.check(is_instance_valid(damage_player_area))
	G.check(is_instance_valid(detection_range))
	G.check(is_instance_valid(attack_max_range_area))
	G.check(is_instance_valid(attack_min_range_area))
	G.check(idle_type == IdleType.WANDER or wake_up_duration_sec > 0)
	G.check(pre_chase_pause_duration_sec > 0.0)
	G.check(attack_pause_duration_sec > 0.0)

	damage_player_radius = damage_player_area.get_child(0).shape.radius
	detection_range_radius = detection_range.get_child(0).shape.radius
	attack_max_range_radius = attack_max_range_area.get_child(0).shape.radius
	attack_min_range_radius = attack_min_range_area.get_child(0).shape.radius

	half_size = Geometry.calculate_half_width_height(
		collision_shape.shape, false)

	# Creat a ray-cast for detected edges of platforms.
	edge_detection_ray_cast = RayCast2D.new()
	edge_detection_ray_cast.target_position = (
		Vector2.DOWN * _EDGE_DETECTION_RAY_CAST_LENGTH
	)
	edge_detection_ray_cast.position = Vector2(-half_size.x, half_size.y)
	set_collision_mask_value(
		Character._NORMAL_SURFACES_COLLISION_MASK_BIT,
		true)
	set_collision_mask_value(
		Character._FALL_THROUGH_FLOORS_COLLISION_MASK_BIT,
		true)
	add_child(edge_detection_ray_cast)

	face_left()


func destroy() -> void:
	queue_free()


func _trigger_attack() -> void:
	G.fatal("Abstract Enemy._trigger_attack not implemented.")


func _physics_process(delta: float) -> void:
	if is_dead:
		return

	just_switched_behaviors = false

	_process_behaviors()
	_process_movement(delta)
	_process_animation()
	_process_sounds()

	# Deal damage when touching the player.
	if (
		is_player_in_body_contact_damage_range and
		is_instance_valid(G.level.player)
	):
		G.level.player.take_damage(_BODY_CONTACT_DAMAGE)


func _process_behaviors() -> void:
	if (
		_does_behavior_require_player(current_behavior) and
		(not is_instance_valid(G.level.player) or
			G.level.player.is_dead)
	):
		# There is no longer a player, so go back home.
		_start_behavior(Behavior.RETURN)
		return

	var current_time := G.time.get_play_time()

	if is_player_in_detection_range:
		last_detection_time_sec = current_time

		# Face the player.
		if _get_direction_sign_to_target(G.level.player.global_position) < 0:
			face_left()
		else:
			face_right()

	var has_reached_edge := not edge_detection_ray_cast.is_colliding()
	if has_reached_edge and _is_behavior_movement(current_behavior):
		if _is_behavior_a_slow_walk(current_behavior):
			_start_behavior(Behavior.STOP_AT_EDGE_FOR_WANDER)
		else:
			_start_behavior(Behavior.STOP_AT_EDGE_FOR_WANDER)
	else:
		match current_behavior:
			Behavior.NONE:
				if idle_type == IdleType.WANDER:
					_start_behavior(Behavior.WANDER_LEFT)
				else:
					_start_behavior(Behavior.SLEEP)
			Behavior.WANDER_LEFT, \
			Behavior.WANDER_RIGHT, \
			Behavior.RETURN:
				if is_player_in_detection_range:
					# We just detected the player. Chase them.
					_start_behavior(Behavior.PRE_CHASE_PAUSE)
				else:
					var distance_squared := (
						global_position.distance_squared_to(current_behavior_target)
					)
					var threshold_squared := (
						_APPROACH_DISTANCE_THRESHOLD * _APPROACH_DISTANCE_THRESHOLD
					)
					if distance_squared < threshold_squared:
						_start_behavior(Behavior.IDLE_PAUSE)
					else:
						# Haven't yet reached the destination, keep walking.
						pass
			Behavior.WAKE_UP:
				if current_time >= current_behavior_end_time_sec:
					# Start chasing after waking.
					_start_behavior(Behavior.CHASE)
				else:
					# Do nothing. Still waking up.
					pass
			Behavior.SLEEP:
				if is_player_in_detection_range:
					_start_behavior(Behavior.WAKE_UP)
				else:
					# Do nothing. Player is not close enough to wake up.
					pass
			Behavior.CHASE, \
			Behavior.STOP_AT_EDGE_FOR_CHASE:
				var time_since_last_detection := (
					current_time - last_detection_time_sec
				)
				if time_since_last_detection >= _LOSE_DETECTION_DELAY_SEC:
					# Player has been out of range for too long, go back.
					_start_behavior(Behavior.RETURN)
				elif is_player_in_detection_range:
					if is_player_in_attack_min_range:
						# Player is too close to attack.
						_start_behavior(Behavior.REPOSITION_FOR_ATTACK)
					elif not is_player_in_attack_max_range:
						# Player is not close enough to attack, but is still in
						# range, keep chasing.
						pass
					else:
						# Player is in attack range.
						_start_behavior(Behavior.ATTACK)
				else:
					# Player is out of detection range, but we've seen them
					# recently, so keep chasing.
					pass
			Behavior.ATTACK:
				if current_time > current_behavior_end_time_sec:
					# Pause before the next attack.
					_start_behavior(Behavior.ATTACK_PAUSE)
				else:
					# Still waiting.
					pass
			Behavior.REPOSITION_FOR_ATTACK:
				if not is_player_in_attack_max_range:
					# They got away. Give chase.
					_start_behavior(Behavior.CHASE)
				if is_player_in_attack_min_range:
					# Make sure we're moving in the current away direction, in case
					# the player moved to our other side.
					current_behavior_target = _calculate_attack_reposition_target()
					_update_behavior_velocity()
				else:
					_start_behavior(Behavior.ATTACK)
			Behavior.IDLE_PAUSE:
				if is_player_in_detection_range:
					# We just detected the player. Chase them.
					_start_behavior(Behavior.PRE_CHASE_PAUSE)
				else:
					if current_time > current_behavior_end_time_sec:
						# Wandering or returning.
						if idle_type == IdleType.WANDER:
							# Wander in a new direction.
							var next_behavior: Behavior
							if previous_behavior == Behavior.WANDER_LEFT:
								next_behavior = Behavior.WANDER_RIGHT
							elif previous_behavior == Behavior.WANDER_RIGHT:
								next_behavior = Behavior.WANDER_LEFT
							else:
								next_behavior = (
									Behavior.WANDER_LEFT if
									randf() > 0.5 else
									Behavior.WANDER_RIGHT
								)
							_start_behavior(next_behavior)
						else:
							# Sleep.
							_start_behavior(Behavior.SLEEP)
					else:
						# Still waiting.
						pass
			Behavior.PLAYER_DIED_PAUSE:
				if current_time > current_behavior_end_time_sec:
					# Go back home.
					_start_behavior(Behavior.RETURN)
				else:
					# Still waiting.
					pass
			Behavior.PRE_CHASE_PAUSE:
				if current_time > current_behavior_end_time_sec:
					# Give chase.
					_start_behavior(Behavior.CHASE)
				else:
					# Still waiting.
					pass
			Behavior.ATTACK_PAUSE:
				if current_time > current_behavior_end_time_sec:
					# Attack again.
					_start_behavior(Behavior.ATTACK)
				else:
					# Still waiting.
					pass
			Behavior.STOP_AT_EDGE_FOR_WANDER:
				if current_time > current_behavior_end_time_sec:
					# Wander in a new direction.
					var next_behavior := (
						Behavior.WANDER_RIGHT if
						previous_behavior == Behavior.WANDER_LEFT else
						Behavior.WANDER_LEFT
					)
					_start_behavior(next_behavior)
				else:
					# Still waiting.
					pass
			_:
				G.fatal()


func _start_behavior(
		next_behavior: Behavior, next_target := Vector2.INF) -> void:
	if (
		_does_behavior_require_player(current_behavior) and
		not G.ensure(is_instance_valid(G.level.player))
	):
		# This new behavior requires a player, but there is none.
		return

	previous_behavior = current_behavior
	previous_behavior_start_time_sec = current_behavior_start_time_sec
	previous_behavior_target = current_behavior_target
	previous_behavior_end_time_sec = current_behavior_end_time_sec

	var current_time := G.time.get_play_time()

	current_behavior = next_behavior
	current_behavior_start_time_sec = current_time
	current_behavior_target = next_target
	current_behavior_end_time_sec = 0.0

	# Very useful logs.
	var behavior_keys := Behavior.keys()
	G.print("%s => %s (for %s)" % [
		behavior_keys[previous_behavior],
		behavior_keys[current_behavior],
		name,
	])

	match current_behavior:
		Behavior.NONE:
			G.fatal("Behavior.NONE should only happen when " +
				"an enemy is first spawned.")
		Behavior.WANDER_LEFT, \
		Behavior.WANDER_RIGHT:
			var distance := randf_range(
				_WANDER_STEP_DISTANCE_MIN,
				_WANDER_STEP_DISTANCE_MAX)
			var direction_sign := (
				-1 if
				current_behavior == Behavior.WANDER_LEFT else
				1
			)
			current_behavior_target = (
				global_position + Vector2(distance * direction_sign, 0)
			)
			_update_behavior_velocity()
		Behavior.RETURN:
			current_behavior_target = spawn_point.global_position
			_update_behavior_velocity()
		Behavior.WAKE_UP:
			current_behavior_end_time_sec = current_time + wake_up_duration_sec
		Behavior.SLEEP:
			if previous_behavior == Behavior.NONE:
				# Do nothing. This enemy should already start asleep.
				pass
			else:
				# Do nothing. The animation will be triggered in
				# _process_animation.
				pass
		Behavior.CHASE:
			current_behavior_target = G.level.player.global_position
			_update_behavior_velocity()
		Behavior.ATTACK:
			current_behavior_end_time_sec = current_time + attack_duration_sec
			_trigger_attack()
		Behavior.REPOSITION_FOR_ATTACK:
			current_behavior_target = _calculate_attack_reposition_target()
			_update_behavior_velocity()
		Behavior.IDLE_PAUSE:
			var duration := randf_range(
				_IDLE_PAUSE_DURATION_MIN_SEC,
				_IDLE_PAUSE_DURATION_MAX_SEC)
			current_behavior_end_time_sec = current_time + duration
		Behavior.PLAYER_DIED_PAUSE:
			current_behavior_end_time_sec = (
				current_time + player_died_pause_duration_sec
			)
		Behavior.PRE_CHASE_PAUSE:
			current_behavior_end_time_sec = (
				current_time + pre_chase_pause_duration_sec
			)
		Behavior.ATTACK_PAUSE:
			current_behavior_end_time_sec = (
				current_time + attack_pause_duration_sec
			)
		Behavior.STOP_AT_EDGE_FOR_WANDER:
			current_behavior_end_time_sec = previous_behavior_end_time_sec
		Behavior.STOP_AT_EDGE_FOR_CHASE:
			current_behavior_end_time_sec = previous_behavior_end_time_sec
		_:
			G.fatal()

	_update_behavior_velocity()

	just_switched_behaviors = previous_behavior != current_behavior


func _update_behavior_velocity() -> void:
	var is_moving := _is_behavior_movement(current_behavior)
	if not is_moving:
		velocity.x = 0.0
		return

	var is_slow := _is_behavior_a_slow_walk(current_behavior)
	var speed := wander_speed if is_slow else chase_speed
	var direction_sign := _get_direction_sign_to_target(
		current_behavior_target)
	velocity.x = speed * direction_sign

	if direction_sign < 0:
		face_left()
	else:
		face_right()


func _calculate_attack_reposition_target() -> Vector2:
	var direction_sign := _get_direction_sign_to_target(
		G.level.player.global_position)
	var target_distance := (
		attack_min_range_radius + G.level.player.half_size.x + 1.0
	)
	return Vector2(
		G.level.player.global_position.x +
			direction_sign * target_distance,
		global_position.y)


func _process_movement(delta: float) -> void:
	was_on_floor = is_on_floor()
	if was_on_floor:
		has_ever_been_on_floor = true

	# Keep on bouncing (if you're that kinda dude).
	if bounces_when_walking and is_on_floor():
		var is_slow := _is_behavior_a_slow_walk(current_behavior)
		var jump_boost := (
			walk_bounce_boost if is_slow else chase_bounce_boost
		)
		velocity.y = -jump_boost

	# Gravity just keeps pulling us all down...
	velocity.y += (
		G.time.scale_delta(delta) * G.settings.default_gravity_acceleration
	)

	move_and_slide()


func _process_animation() -> void:
	if current_behavior == Behavior.ATTACK:
		play_animation("attack")
	elif current_behavior == Behavior.WAKE_UP:
		play_animation("wake_up")
	elif current_behavior == Behavior.SLEEP:
		play_animation("sleep")
	elif is_on_floor():
		if _is_behavior_movement(current_behavior):
			play_animation("walk")
		else:
			play_animation("rest")
	else:
		if velocity.y > 0:
			play_animation("jump_fall")
		else:
			play_animation("jump_rise")


func _process_sounds() -> void:
	if not has_ever_been_on_floor:
		return

	if just_switched_behaviors:
		match current_behavior:
			Behavior.WAKE_UP:
				play_sound("awaken")
				return
			Behavior.PRE_CHASE_PAUSE:
				play_sound("detected")
				return
			Behavior.ATTACK:
				play_sound("attack")
				return
			_:
				pass

	if just_jumped:
		play_sound("jump")
	elif just_landed:
		play_sound("land")


func play_sound(sound_name: String) -> void:
	match sound_name:
		"jump":
			# TODO: ALDEN: Make that magic sound stuff happen, baby.
			pass
		"land":
			# TODO: ALDEN: Make that magic sound stuff happen, baby.
			pass
		"ouch":
			# TODO: [Optional, might be triggered on the player's attack] ALDEN: Make that magic sound stuff happen, baby.
			pass
		"die":
			# TODO: ALDEN: Make that magic sound stuff happen, baby.
			pass
		"attack":
			# TODO: [Optional] ALDEN: Make that magic sound stuff happen, baby.
			pass
		"awaken":
			# TODO: [Optional] ALDEN: Make that magic sound stuff happen, baby.
			pass
		"detected":
			# TODO: [Optional] ALDEN: Make that magic sound stuff happen, baby.
			pass
		_:
			G.fatal()


func face_left() -> void:
	animated_sprite.flip_h = faces_right_by_default
	edge_detection_ray_cast.position = Vector2(-half_size.x, half_size.y)


func face_right() -> void:
	animated_sprite.flip_h = not faces_right_by_default
	edge_detection_ray_cast.position = Vector2(half_size.x, half_size.y)


func play_animation(animation_name: String) -> void:
	# TODO: Hook-up the other animations.
	if animation_name != "idle":
		return
	animated_sprite.play(animation_name)


func take_damage(damage: int) -> void:
	var modified_damage := floori(damage / defense)
	current_health = maxi(current_health - modified_damage, 0)
	if current_health == 0:
		die()
	else:
		play_sound("ouch")


func die() -> void:
	play_sound("die")


func _on_damage_player_area_body_entered(body: Node2D) -> void:
	if not body is Player:
		return
	is_player_in_body_contact_damage_range = true


func _on_damage_player_area_body_exited(body: Node2D) -> void:
	if not body is Player:
		return
	is_player_in_body_contact_damage_range = false


func _on_detection_range_body_entered(body: Node2D) -> void:
	if not body is Player:
		return
	is_player_in_detection_range = true


func _on_detection_range_body_exited(body: Node2D) -> void:
	if not body is Player:
		return
	is_player_in_detection_range = false


func _on_attack_max_range_body_entered(body: Node2D) -> void:
	if not body is Player:
		return
	is_player_in_attack_max_range = true


func _on_attack_max_range_body_exited(body: Node2D) -> void:
	if not body is Player:
		return
	is_player_in_attack_max_range = false


func _on_attack_min_range_body_entered(body: Node2D) -> void:
	if not body is Player:
		return
	# Ignore too-close if the range is very small.
	if attack_min_range_radius < 1.0:
		return
	is_player_in_attack_min_range = true


func _on_attack_min_range_body_exited(body: Node2D) -> void:
	if not body is Player:
		return
	# Ignore too-close if the range is very small.
	if attack_min_range_radius < 1.0:
		return
	is_player_in_attack_min_range = false
