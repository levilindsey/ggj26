class_name Enemy
extends CharacterBody2D


enum Type {
	DUST_BUNNY,
	RAT,
	GHOST,
	NIGHTMARE,
	SPIDER,
}


@export var type := Type.DUST_BUNNY

@export var animated_sprite: AnimatedSprite2D

@export var faces_right_by_default := false

@export var max_health := 100

@export var defense := 1.0

@onready var current_health := max_health

var spawn_point: EnemySpawnPoint

var was_on_floor := false

var has_ever_been_on_floor := false

var just_jumped := false

var is_moving := false

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
	face_left()


func destroy() -> void:
	queue_free()


func _physics_process(_delta: float) -> void:
	if is_dead:
		return

	_process_movement()
	_process_animation()
	_process_sounds()


func _process_movement() -> void:
	was_on_floor = is_on_floor()
	if was_on_floor:
		has_ever_been_on_floor = true

	# TODO: Add enemy behaviors.
	# Use these:
	# - is_moving
	# - just_jumped
	# - face_left()
	# - face_right()
	pass


func _process_animation() -> void:
	if is_on_floor():
		if is_moving:
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
