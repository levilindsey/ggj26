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


func play_sound(sound_name: StringName) -> void:
	if not G.ensure(STREAM_PLAYERS_BY_NAME.has(sound_name)):
		return

	var stream_player: AudioStreamPlayer = STREAM_PLAYERS_BY_NAME[sound_name]
	if not stream_player.playing:
		stream_player.play()


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
		stream_player.play()

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
