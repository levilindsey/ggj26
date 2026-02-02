class_name AudioMain
extends Node2D


@export var theme_fade_duration_sec := 0.2

@export var mute_volume := -80.0

@export var main_theme_volume := 0.0
@export var menu_theme_volume := 0.0

@onready var STREAM_PLAYERS_BY_NAME := {
	"dino_theme" = %DinoTheme,
	"girl_theme" = %GirlTheme,
	"pirate_theme" = %PirateTheme,
	"western_theme" = %WesternTheme,
	"wizard_theme" = %WizardTheme,
	"wiz_mask" = %WizardMask,
	"dino_mask" = %DinoMask,
	"cowboy_mask" = %CowboyMask,
	"pirate_mask" = %PirateMask,
	"dino_bite" = %DinoBite,
	"cowboy_gun" = %CowboyGun,
	"pirate_sword" = %PirateSword,
	"wiz_spell" = %WizSpell,
	"girl_attack" = %GirlAttack,
	"girl_damage" = %GirlDamage,
	"girl_footsteps_loop" = %GirlFootstepsLoop,
	"girl_jump" = %GirlJump,
	"dino_feet" = %DinoFeet,
	"dino_jump" = %DinoJump,
	"cowboy_jump" = %CowboyJump,
	"wizard_jump" = %WizJump,
	"bird_flap" = %BirdFlap,
	"girl_death" = %GirlDeath,
	"ice_shatter" = %IceShatter,
	"click" = %ClickStreamPlayer,
	"godot_splash" = %ClickStreamPlayer,
	"scg_splash" = %SnoringCatStreamPlayer,
	"success" = %SuccessCadenceStreamPlayer,
	"failure" = %FailureCadenceStreamPlayer,
	"achievement" = %AchievementStreamPlayer,
}

var initial_volumes := {}

var current_theme: AudioStreamPlayer


func _enter_tree() -> void:
	G.audio = self


func _ready() -> void:
	for player_name in STREAM_PLAYERS_BY_NAME:
		var player: AudioStreamPlayer = STREAM_PLAYERS_BY_NAME[player_name]
		initial_volumes[player_name] = player.volume_db


func play_sound(sound_name: StringName, force_restart := false) -> void:
	if not G.ensure(STREAM_PLAYERS_BY_NAME.has(sound_name)):
		return

	var stream_player: AudioStreamPlayer = STREAM_PLAYERS_BY_NAME[sound_name]
	if not stream_player.playing or force_restart:
		stream_player.play.call()


func stop_sound(sound_name: StringName) -> void:
	if not G.ensure(STREAM_PLAYERS_BY_NAME.has(sound_name)):
		return

	var stream_player: AudioStreamPlayer = STREAM_PLAYERS_BY_NAME[sound_name]
	if stream_player.playing:
		stream_player.stop()


func fade_to_mask_theme(mask_type: Player.MaskType) -> void:
	var player_name := get_player_name_for_mask(mask_type)
	fade_to_theme(player_name)


func get_player_name_for_mask(mask_type: Player.MaskType) -> String:
	match mask_type:
		Player.MaskType.NONE:
			return "girl_theme"
		Player.MaskType.COWBOY:
			return "western_theme"
		Player.MaskType.PIRATE:
			return "pirate_theme"
		Player.MaskType.WIZARD:
			return "wizard_theme"
		Player.MaskType.DINOSAUR:
			return "dino_theme"
		Player.MaskType.CHICKEN:
			return "girl_theme"
		_:
			G.fatal()
			return ""


func fade_to_theme(theme_name: String) -> void:
	if is_instance_valid(current_theme):
		fade_out(current_theme)
	current_theme = STREAM_PLAYERS_BY_NAME[theme_name]
	fade_in(current_theme, initial_volumes[theme_name])


func fade_to_main_theme() -> void:
	fade_to_mask_theme(Player.MaskType.NONE)


func fade_in(stream_player: AudioStreamPlayer, volume: float) -> void:
	if G.settings.mute_music:
		volume = mute_volume

	if not stream_player.playing:
		stream_player.volume_db = mute_volume
		stream_player.play.call()

	var tween := create_tween()
	tween.set_pause_mode(Tween.TWEEN_PAUSE_PROCESS)
	tween.tween_property(
		stream_player,
		"volume_db",
		volume,
		theme_fade_duration_sec)

	await tween.step_finished
	# Ensure the stream is still playing, just in case we somehow end up with
	# overlapping tweens (the latest tween should end up winning).
	stream_player.stream_paused = false


func fade_out(stream_player: AudioStreamPlayer) -> void:
	if not stream_player.playing:
		return

	var tween := create_tween()
	tween.set_pause_mode(Tween.TWEEN_PAUSE_PROCESS)
	tween.tween_property(
		stream_player,
		"volume_db",
		mute_volume,
		theme_fade_duration_sec)

	await tween.step_finished
	# Ensure the stream is still playing, just in case we somehow end up with
	# overlapping tweens (the latest tween should end up winning).
	stream_player.stream_paused = true


func apply_music_mute() -> void:
	# Apply mute setting to currently playing music streams.
	var menu_player := %MenuThemeStreamPlayer
	var main_player := %MainThemeStreamPlayer

	if menu_player.playing and not menu_player.stream_paused:
		menu_player.volume_db = mute_volume if (
			G.settings.mute_music
		) else menu_theme_volume

	if main_player.playing and not main_player.stream_paused:
		main_player.volume_db = mute_volume if (
			G.settings.mute_music
		) else main_theme_volume


func play_enemy_sound(
	sound_name: StringName,
	enemy_type: Enemy.Type,
	force_restart := false
) -> void:
	var play = func(p_sound_name: StringName):
		play_sound(p_sound_name, force_restart)
	# TODO: ALDEN
	match sound_name:
		"jump":
			#play.call("enemy_jump")
			pass
		"land":
			#play.call("enemy_land")
			pass
		"ouch":
			#play.call("enemy_ouch")
			pass
		"die":
			#play.call("enemy_die")
			pass
		"attack":
			#play.call("enemy_attack")
			pass
		"awaken":
			#play.call("enemy_awaken")
			pass
		"detected":
			#play.call("enemy_detected_player")
			pass
		_:
			G.fatal()
	#match enemy_type:
		#Enemy.Type.DUST_BUNNY:
			#pass
		#Enemy.Type.RAT:
			#pass
		#Enemy.Type.GHOST:
			#pass
		#Enemy.Type.NIGHTMARE:
			#pass
		#Enemy.Type.SPIDER:
			#pass
		#Enemy.Type.HAND:
			#pass
		#_:
			#G.fatal()


func play_player_sound(
	sound_name: String,
	force_restart := false
) -> void:
	var play = func(p_sound_name: StringName):
		play_sound(p_sound_name, force_restart)

	# TODO: ALDEN
	match sound_name:
		"spawn":
			#play.call("spawn")
			pass
		"mask":
			match G.level.player.mask_type:
				Player.MaskType.NONE:
					#play.call("girl_mask")
					pass
				Player.MaskType.COWBOY:
					play.call("cowboy_mask")
					pass
				Player.MaskType.PIRATE:
					play.call("pirate_mask")
					pass
				Player.MaskType.WIZARD:
					play.call("wiz_mask")
					pass
				Player.MaskType.DINOSAUR:
					play.call("dino_mask")
					pass
				Player.MaskType.CHICKEN:
					#play.call("chicken_mask")
					pass
				_:
					G.fatal()
		"ability":
			match G.level.player.mask_type:
				Player.MaskType.NONE:
					play.call("girl_attack")
					pass
				Player.MaskType.COWBOY:
					play.call("cowboy_gun")
					pass
				Player.MaskType.PIRATE:
					play.call("pirate_sword")
					pass
				Player.MaskType.WIZARD:
					play.call("wiz_spell")
					pass
				Player.MaskType.DINOSAUR:
					play.call("dino_bite")
					pass
				Player.MaskType.CHICKEN:
					#play.call("chicken_ability")
					pass
				_:
					G.fatal()
		"jump":
			match G.level.player.mask_type:
				Player.MaskType.NONE:
					play.call("girl_jump")
					pass
				Player.MaskType.COWBOY:
					play.call("cowboy_jump")
					pass
				Player.MaskType.PIRATE:
					play.call("cowboy_jump")
					play.call("bird_flap")
					pass
				Player.MaskType.WIZARD:
					play.call("wizard_jump")
					pass
				Player.MaskType.DINOSAUR:
					play.call("dino_jump")
					pass
				Player.MaskType.CHICKEN:
					#play.call("girl_jump")
					pass
				_:
					G.fatal()
			pass
		"land":
			stop_sound("bird_flap")
			pass
		"walk":
			match G.level.player.mask_type:
				Player.MaskType.NONE:
					play.call("girl_footsteps_loop")
					pass
				Player.MaskType.COWBOY:
					play.call("girl_footsteps_loop")
					pass
				Player.MaskType.PIRATE:
					play.call("girl_footsteps_loop")
					pass
				Player.MaskType.WIZARD:
					play.call("girl_footsteps_loop")
					pass
				Player.MaskType.DINOSAUR:
					play.call("dino_feet")
					pass
				Player.MaskType.CHICKEN:
					play.call("girl_footsteps_loop")
					pass
				_:
					G.fatal()
		"ouch":
			play.call("girl_damage")
			pass
		"die":
			play_sound("girl_death")
			pass
		"mask_scroll":
			#play.call("mask_scroll")
			pass
		"mask_pickup":
			match G.level.player.mask_type:
				Player.MaskType.NONE:
					#play.call("girl_mask")
					pass
				Player.MaskType.COWBOY:
					play.call("cowboy_mask")
					pass
				Player.MaskType.PIRATE:
					play.call("pirate_mask")
					pass
				Player.MaskType.WIZARD:
					play.call("wiz_mask")
					pass
				Player.MaskType.DINOSAUR:
					play.call("dino_mask")
					pass
				Player.MaskType.CHICKEN:
					#play.call("chicken_mask")
					pass
				_:
					G.fatal()
		_:
			G.fatal()


func stop_player_sound(sound_name: String) -> void:
	match sound_name:
		"walk":
			stop_sound("girl_footsteps_loop")
			stop_sound("dino_feet")
