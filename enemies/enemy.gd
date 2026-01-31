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
	WAKE_UP,
	GO_TO_SLEEP,
	CHASE,
	RETURN,
	ATTACK,
	REPOSITION_FOR_ATTACK,
	PAUSE,
	JUMP,
}


const _BODY_CONTACT_DAMAGE := 20
const _LOSE_DETECTION_DELAY_SEC := 3.5


@export var type := Type.DUST_BUNNY

@export var animated_sprite: AnimatedSprite2D
@export var damage_player_area: Area2D
@export var detection_area: Area2D
@export var attack_max_range_area: Area2D
@export var attack_min_range_area: Area2D

@export var faces_right_by_default := false

@export var max_health := 100

@export var defense := 1.0

@onready var current_health := max_health

var spawn_point: EnemySpawnPoint

var current_behavior := Behavior.NONE
var previous_behavior := Behavior.NONE
var current_behavior_end_time_sec := 0.0
var current_behavior_start_time_sec := 0.0
var previous_behavior_start_time_sec := 0.0
var current_behavior_target := Vector2.INF
var previous_behavior_target := Vector2.INF

var is_player_in_body_contact_damage_range := false
var is_player_in_detection_range := false
var is_player_in_attack_max_range := false
var is_player_in_attack_min_range := false
var last_detection_time_sec := 0.0

var was_on_floor := false

var has_ever_been_on_floor := false

var just_jumped := false

var is_wandering: bool:
	get:
		return (
			current_behavior == Behavior.WANDER_LEFT or
			current_behavior == Behavior.WANDER_RIGHT
		)

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


func _ready() -> void:
	G.check(is_instance_valid(animated_sprite))
	G.check(is_instance_valid(damage_player_area))
	G.check(is_instance_valid(detection_area))
	G.check(is_instance_valid(attack_max_range_area))
	G.check(is_instance_valid(attack_min_range_area))
	face_left()


func destroy() -> void:
	queue_free()


func _physics_process(_delta: float) -> void:
	if is_dead:
		return

	_process_behaviors()
	_process_movement()
	_process_animation()
	_process_sounds()

	# Deal damage when touching the player.
	if (
		is_player_in_body_contact_damage_range and
		is_instance_valid(G.level.player)
	):
		G.level.player.take_damage(_BODY_CONTACT_DAMAGE)


func _process_behaviors() -> void:
	var current_time := G.time.get_play_time()

	match current_behavior:
		Behavior.NONE:
			# TODO: Implement behaviors.
			pass
		Behavior.WANDER_LEFT:
			# TODO: Implement behaviors.
			pass
		Behavior.WANDER_RIGHT:
			# TODO: Implement behaviors.
			pass
		Behavior.WAKE_UP:
			# TODO: Implement behaviors.
			pass
		Behavior.GO_TO_SLEEP:
			# TODO: Implement behaviors.
			pass
		Behavior.CHASE:
			var time_since_last_detection := current_time - last_detection_time_sec
			if not is_instance_valid(G.level.player) or G.level.player.is_dead:
				# No player to chase.
				_trigger_behavior(Behavior.RETURN)
			elif is_player_in_detection_range:
				if is_player_in_attack_min_range:
					# Player is too close to attack.
					_trigger_behavior(Behavior.REPOSITION_FOR_ATTACK)
				elif not is_player_in_attack_max_range:
					# Player is not close enough to attack, but is still in
					# range, keep chasing.
					last_detection_time_sec = current_time
				else:
					# Player is in attack range.
					_trigger_behavior(Behavior.ATTACK)
			elif time_since_last_detection >= _LOSE_DETECTION_DELAY_SEC:
				# Player has been out of range for too long, go back.
				_trigger_behavior(Behavior.RETURN)
			else:
				# Player is out of detection range, but we've seen them
				# recently, so keep chasing.
				pass
		Behavior.RETURN:
			# TODO: Implement behaviors.
			pass
		Behavior.ATTACK:
			# TODO: Implement behaviors.
			pass
		Behavior.REPOSITION_FOR_ATTACK:
			# TODO: Implement behaviors.
			pass
		Behavior.PAUSE:
			# TODO: Implement behaviors.
			pass
		Behavior.JUMP:
			# TODO: Implement behaviors.
			pass
		_:
			G.fatal()

	# TODO: Add enemy behaviors.
	# Use these:
	#
	# - is_moving
	# - just_jumped
	# - face_left()
	# - face_right()
	#
	#var current_behavior := Behavior.NONE
	#var previous_behavior := Behavior.NONE
	#var current_behavior_end_time_sec := 0
	#var current_behavior_start_time_sec := 0
	#var previous_behavior_start_time_sec := 0
	#var current_behavior_target := Vector2.INF
	#var previous_behavior_target := Vector2.INF
	pass


func _trigger_behavior(
		next_behavior: Behavior, next_target := Vector2.INF) -> void:
	previous_behavior = current_behavior
	previous_behavior_start_time_sec = current_behavior_start_time_sec
	previous_behavior_target = current_behavior_target

	current_behavior = next_behavior
	current_behavior_start_time_sec = G.time.get_play_time()
	current_behavior_target = next_target
	current_behavior_end_time_sec = 0.0

	match current_behavior:
		Behavior.NONE:
			# TODO: Implement behaviors.
			pass
		Behavior.WANDER_LEFT:
			# TODO: Implement behaviors.
			pass
		Behavior.WANDER_RIGHT:
			# TODO: Implement behaviors.
			pass
		Behavior.WAKE_UP:
			# TODO: Implement behaviors.
			pass
		Behavior.GO_TO_SLEEP:
			# TODO: Implement behaviors.
			pass
		Behavior.CHASE:
			# TODO: Implement behaviors.
			pass
		Behavior.RETURN:
			# TODO: Implement behaviors.
			pass
			current_behavior_target = spawn_point.global_position
		Behavior.ATTACK:
			# TODO: Implement behaviors.
			pass
		Behavior.REPOSITION_FOR_ATTACK:
			# TODO: Implement behaviors.
			pass
		Behavior.PAUSE:
			# TODO: Implement behaviors.
			pass
		Behavior.JUMP:
			# TODO: Implement behaviors.
			pass
		_:
			G.fatal()


func _process_movement() -> void:
	was_on_floor = is_on_floor()
	if was_on_floor:
		has_ever_been_on_floor = true

	# TODO: Add enemy behaviors.
	pass


func _process_animation() -> void:
	if is_on_floor():
		if is_wandering:
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
			# TODO: ALDEN: Make that magic sound stuff happen, baby.
			pass
		"die":
			# TODO: ALDEN: Make that magic sound stuff happen, baby.
			pass
		_:
			G.fatal()


func face_left() -> void:
	animated_sprite.flip_h = faces_right_by_default


func face_right() -> void:
	animated_sprite.flip_h = not faces_right_by_default


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


func _on_detection_area_body_entered(body: Node2D) -> void:
	if not body is Player:
		return
	is_player_in_detection_range = true


func _on_detection_area_body_exited(body: Node2D) -> void:
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
	is_player_in_attack_min_range = true


func _on_attack_min_range_body_exited(body: Node2D) -> void:
	if not body is Player:
		return
	is_player_in_attack_min_range = false
