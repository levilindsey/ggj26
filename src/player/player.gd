class_name Player
extends Character


# FIXME: LEFT OFF HERE:
# - Other enemies:
#   - Movement/behavior settings
#     - Ghost will have some custom stuff...
#   - Attacks (mostly move a hitbox around to match the animation):
#     - Nightmare swipe
#     - Spider reach stomp
#     - Ghost rush
#     - Rat lunge
#     - Make the dust bunny do a much higher sort of bounce attack, less lunge (calculate parabolic motion time for heigh, and use that to get horizontal speed based off current distance).
# - Player abilities:
#   - Movement settings for each mask
#   - Abilities:
#     - Pirate sword
#     - Cowboy gun
#     - Wizard ice spike
#     - Dinosaur chomp
#     - Chicken buh-cawk! (gonna need a sound for that...)
# - Animations:
#   - 4-frame walk for each
#   - 2-frame rise for each
#   - 2-frame fall for each
#   - Simple idle
#   - Custom attack for each
#   - Possibly "wake-up" and "sleep", should be simple though
# - END GAME CONDITION:
#   - Cookie jar and cookie sprite
#   - Credits panel



enum MaskType {
	NONE,
	COWBOY,
	PIRATE,
	WIZARD,
	DINOSAUR,
	CHICKEN,
}

const _MAX_HEALTH := 100
const _INVINCIBILITY_DURATION_SEC := 1.0
const _INVINCIBILITY_BLINK_PERIOD_SEC := 0.1
const _DEATH_GAME_OVER_DELAY_SEC := 0.3
const _MASK_SWAP_COOLDOWN_SEC := 1.0


@export var mask_type := MaskType.NONE

@export var defense := 1.0

@export var abilty_duration_sec := 0.5

var last_ability_start_time_sec := -INF
var is_ability_active: bool:
	get:
		return (
			last_ability_start_time_sec + abilty_duration_sec >
			G.time.get_play_time()
		)

var is_strong_defense: bool:
	get:
		return defense > 1.5

var current_masks: Array[MaskType] = [MaskType.NONE]
var selected_mask_index := 0
var previous_mask_type := MaskType.NONE

var last_mask_swap_time_sec := -INF

var current_health := _MAX_HEALTH
var health_progress: float:
	get:
		return current_health / float(_MAX_HEALTH)

var half_size := Vector2.INF

var last_invincibility_start_time_sec := -INF
var is_invincible: bool:
	get:
		return (
			last_invincibility_start_time_sec + _INVINCIBILITY_DURATION_SEC >
			G.time.get_play_time()
		)

var is_dead: bool:
	get:
		return current_health == 0


func _ready() -> void:
	super._ready()
	half_size = Geometry.calculate_half_width_height(
		collision_shape.shape,
		false)


func destroy() -> void:
	queue_free()


func _trigger_ability() -> void:
	G.fatal("Abstract Player._trigger_ability is not implemented")


func _process(delta: float) -> void:
	super._process(delta)
	_process_invincibility_blink()


func _process_invincibility_blink() -> void:
	if not is_invincible:
		visible = true
	else:
		var elapsed_invincibility_time := (
			G.time.get_play_time() - last_invincibility_start_time_sec
		)
		visible = (
			floori(
				elapsed_invincibility_time /
				(_INVINCIBILITY_BLINK_PERIOD_SEC / 2.0)
			) % 2 == 0
		)


func _physics_process(delta: float) -> void:
	if is_dead:
		return
	super._physics_process(delta)

	if Input.is_action_just_pressed("ability"):
		last_ability_start_time_sec = G.time.get_play_time()
		_trigger_ability()
		animator.play("attack")
		play_sound("ability")
	if Input.is_action_just_pressed("mask"):
		# Don't allow rapid swaps.
		var current_time := G.time.get_play_time()
		if current_time < last_mask_swap_time_sec + _MASK_SWAP_COOLDOWN_SEC:
			return

		var next_mask_type := current_masks[selected_mask_index]
		if next_mask_type == mask_type:
			# Reselecting the same mask toggles it off.
			next_mask_type = MaskType.NONE
		if next_mask_type == mask_type:
			# We already are wearing this mask (only happens for the girl).
			return
		G.level.swap_mask(next_mask_type)
		G.hud.update_masks()
		play_sound("mask")
	if Input.is_action_just_pressed("scroll_left"):
		selected_mask_index = (
			(selected_mask_index - 1 + current_masks.size()) %
			current_masks.size()
		)
		G.hud.update_masks()
		play_sound("mask_scroll")
	if Input.is_action_just_pressed("scroll_right"):
		selected_mask_index = (selected_mask_index + 1) % current_masks.size()
		G.hud.update_masks()
		play_sound("mask_scroll")


func _update_actions() -> void:
	super._update_actions()


func _process_animation() -> void:
	if is_ability_active:
		# Do nothing. "attack" animation is already playing, and triggering it
		# again would cause looping.
		pass
	else:
		super._process_animation()


func play_sound(sound_name: String) -> void:
	match sound_name:
		"spawn":
			# TODO: ALDEN: Make that magic sound stuff happen, baby.
			pass
		"mask":
			match mask_type:
				MaskType.NONE:
					# TODO: ALDEN: Make that magic sound stuff happen, baby.
					pass
				MaskType.COWBOY:
					# TODO: ALDEN: Make that magic sound stuff happen, baby.
					pass
				MaskType.PIRATE:
					# TODO: ALDEN: Make that magic sound stuff happen, baby.
					pass
				MaskType.WIZARD:
					# TODO: ALDEN: Make that magic sound stuff happen, baby.
					pass
				MaskType.DINOSAUR:
					# TODO: ALDEN: Make that magic sound stuff happen, baby.
					pass
				MaskType.CHICKEN:
					# TODO: ALDEN: Make that magic sound stuff happen, baby.
					pass
				_:
					G.fatal()
		"ability":
			match mask_type:
				MaskType.NONE:
					# TODO: ALDEN: Make that magic sound stuff happen, baby.
					pass
				MaskType.COWBOY:
					# TODO: ALDEN: Make that magic sound stuff happen, baby.
					pass
				MaskType.PIRATE:
					# TODO: ALDEN: Make that magic sound stuff happen, baby.
					pass
				MaskType.WIZARD:
					# TODO: ALDEN: Make that magic sound stuff happen, baby.
					pass
				MaskType.DINOSAUR:
					# TODO: ALDEN: Make that magic sound stuff happen, baby.
					pass
				MaskType.CHICKEN:
					# TODO: ALDEN: Make that magic sound stuff happen, baby.
					pass
				_:
					G.fatal()
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
		"mask_scroll":
			# TODO: ALDEN: Make that magic sound stuff happen, baby.
			pass
		"mask_pickup":
			# TODO: ALDEN: Make that magic sound stuff happen, baby.
			pass
		_:
			G.fatal()


func pick_up_mask(p_mask_type: MaskType) -> void:
	if current_masks.has(p_mask_type):
		return
	current_masks.append(p_mask_type)
	G.level.swap_mask(p_mask_type)
	play_sound("mask_pickup")


func take_damage(damage: int) -> void:
	if is_dead:
		# Ignore damage. Already dead.
		return
	if is_invincible:
		# Ignore damage. Still invincible.
		return

	var current_time := G.time.get_play_time()

	var previous_health := current_health
	var modified_damage := floori(damage / defense)
	current_health = maxi(current_health - modified_damage, 0)

	if current_health == 0:
		die()
	else:
		G.print(
			"Player damaged: %s => %s" % [previous_health, current_health],
			ScaffolderLog.CATEGORY_GAME_STATE)
		last_invincibility_start_time_sec = current_time
		play_sound("ouch")

	G.hud.update_health()


func die() -> void:
	G.print("Player died", ScaffolderLog.CATEGORY_GAME_STATE)
	play_sound("die")
	G.level.game_over()


func copy(other: Player) -> void:
	global_position = other.global_position
	velocity = other.velocity
	current_health = other.current_health
	current_masks = other.current_masks
	previous_mask_type = other.mask_type

	if mask_type == MaskType.NONE:
		# When toggling off a mask, to revert back to the girl, remain with the
		# previous mask selected.
		selected_mask_index = other.selected_mask_index
	else:
		selected_mask_index = current_masks.find(mask_type)
	G.check(selected_mask_index >= 0)


static func get_palette_swap_index_for_mask(p_mask_type: MaskType) -> int:
	match p_mask_type:
		MaskType.NONE:
			return 1
		MaskType.COWBOY:
			return 3
		MaskType.PIRATE:
			return 4
		MaskType.WIZARD:
			return 5
		MaskType.DINOSAUR:
			return 2
		MaskType.CHICKEN:
			return 1
		_:
			G.fatal()
			return 0
