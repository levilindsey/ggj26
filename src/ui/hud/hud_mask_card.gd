@tool
class_name HudMaskCard
extends PanelContainer


@export var mask_type := Player.MaskType.NONE:
	set(value):
		mask_type = value
		_update_texture()

@export var is_collected := false:
	set(value):
		is_collected = value
		%Icon.visible = value

@export var is_selected := false:
	set(value):
		is_selected = value
		%Highlight.visible = value


func _ready() -> void:
	_update_texture()


func _update_texture() -> void:
	if Engine.is_editor_hint():
		return
	if not is_node_ready():
		return

	if mask_type == Player.MaskType.NONE:
		%Icon.texture = null
		return

	var texture := G.settings.get_mask_icon_for_mask_type(mask_type)

	var image := texture.get_image()
	var image_size := Vector2(image.get_width(), image.get_height())

	%Icon.size = image_size
	%Icon.position = -image_size / 2.0
	%Icon.texture = texture
	#custom_minimum_size = image_size
