class_name Settings
extends Resource


# --- General configuration ---

@export var dev_mode := true
@export var draw_annotations := false
@export var show_debug_console := false
@export var show_debug_player_state := false

@export var start_in_game := true
@export var full_screen := false
@export var move_preview_windows_to_other_display := true
@export var mute_music := false
@export var pauses_on_focus_out := true
@export var is_screenshot_hotkey_enabled := true
@export var start_with_all_masks := false

@export var show_hud := true

# --- Game-specific configuration ---

@export var default_gravity_acceleration := 5000.0

@export var default_level_scene: PackedScene

@export_group("Player scenes")
@export var girl_scene: PackedScene
@export var cowboy_scene: PackedScene
@export var pirate_scene: PackedScene
@export var wizard_scene: PackedScene
@export var dinosaur_scene: PackedScene
@export var chicken_scene: PackedScene
@export_group("")

@export_group("Enemy scenes")
@export var dust_bunny_scene: PackedScene
@export var rat_scene: PackedScene
@export var ghost_scene: PackedScene
@export var nightmare_scene: PackedScene
@export var spider_scene: PackedScene
@export_group("")

@export var color_swap_palettes: Texture2D

@export var color_swap_original_palette_row_index := 0



func get_player_for_mask_type(type: Player.MaskType) -> PackedScene:
	match type:
		Player.MaskType.NONE:
			return girl_scene
		Player.MaskType.COWBOY:
			return cowboy_scene
		Player.MaskType.PIRATE:
			return pirate_scene
		Player.MaskType.WIZARD:
			return wizard_scene
		Player.MaskType.DINOSAUR:
			return dinosaur_scene
		Player.MaskType.CHICKEN:
			return chicken_scene
		_:
			G.fatal()
			return null


func get_scene_for_enemy_type(type: Enemy.Type) -> PackedScene:
	match type:
		Enemy.Type.DUST_BUNNY:
			return dust_bunny_scene
		Enemy.Type.RAT:
			return rat_scene
		Enemy.Type.GHOST:
			return ghost_scene
		Enemy.Type.NIGHTMARE:
			return nightmare_scene
		Enemy.Type.SPIDER:
			return spider_scene
		_:
			G.fatal()
			return null


@export_group("Logs")
## Logs with these categories won't be shown.
@export var excluded_log_categories: Array[StringName] = [
	#ScaffolderLog.CATEGORY_DEFAULT,
	#ScaffolderLog.CATEGORY_CORE_SYSTEMS,
	ScaffolderLog.CATEGORY_SYSTEM_INITIALIZATION,
	ScaffolderLog.CATEGORY_PLAYER_ACTIONS,
	#ScaffolderLog.CATEGORY_INTERACTION,
	#ScaffolderLog.CATEGORY_BEHAVIORS,
	#ScaffolderLog.CATEGORY_GAME_STATE,
]
## If true, warning logs will be shown regardless of category filtering.
@export var force_include_log_warnings := true
@export var include_category_in_logs := true
@export var include_peer_id_in_logs := true
@export var verbosity := ScaffolderLog.Verbosity.NORMAL
@export_group("")
