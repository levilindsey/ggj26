class_name Player
extends Character


enum MaskType {
	NONE,
	COWBOY,
	PIRATE,
	WIZARD,
	DINOSAUR,
	CHICKEN,
}

const _MAX_HEALTH := 100
const _RESPAWN_DELAY_SEC := 2.0


@export var mask_type := MaskType.NONE

@export var defense := 1.0

var current_health := _MAX_HEALTH

var is_dead: bool:
	get:
		return current_health == 0


func _ready() -> void:
	super._ready()
	play_sound("spawn")


func destroy() -> void:
	queue_free()


func _physics_process(delta: float) -> void:
	if is_dead:
		return
	super._physics_process(delta)


func _update_actions() -> void:
	super._update_actions()


func play_sound(sound_name: String) -> void:
	match sound_name:
		"spawn":
			# TODO: ALDEN: Make that magic sound stuff happen, baby.
			pass
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


func take_damage(damage: int) -> void:
	var modified_damage := floori(damage / defense)
	current_health = maxi(current_health - modified_damage, 0)
	if current_health == 0:
		die()
	else:
		play_sound("ouch")


func die() -> void:
	play_sound("die")
	await get_tree().create_timer(_RESPAWN_DELAY_SEC).timeout
	G.level.reset()
