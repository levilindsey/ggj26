class_name MaskPickup
extends Node2D


const _OSCILLATION_PERIOD_SEC := 3.0
const _OSCILLATION_AMPLITUDE := 4.0

@export var mask_type := Player.MaskType.COWBOY:
	set(value):
		mask_type = value
		_update_texture()


var enabled: bool:
	get:
		return visible
	set(value):
		visible = value


func _enter_tree() -> void:
	if Engine.is_editor_hint():
		return
	G.level.mask_pickups.append(self)


func _exit_tree() -> void:
	if Engine.is_editor_hint():
		return
	G.level.mask_pickups.erase(self)


func _update_texture() -> void:
	if Engine.is_editor_hint():
		return

	if mask_type == Player.MaskType.NONE:
		%TextureRect.texture = null
		return

	var texture := G.settings.get_mask_icon_for_mask_type(mask_type)

	var image := texture.get_image()
	var size := Vector2(image.get_width(), image.get_height())

	%TextureRect.size = size
	%TextureRect.position = -size / 2.0
	%TextureRect.texture = texture


func _on_area_2d_body_entered(body: Node2D) -> void:
	if not body is Player:
		return
	if not enabled:
		return
	enabled = false
	var player := body as Player
	player.pick_up_mask(mask_type)
