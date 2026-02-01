class_name PaletteSwapper
extends ShaderMaterial


const _MAX_COLOR_COUNT := 32
const _MAX_PALETTE_COUNT := 8

@export var swap_index := 0:
	set(value):
		swap_index = value
		set_shader_parameter(&"swap_index", swap_index)


func set_up() -> void:
	var palettes := G.settings.color_swap_palettes
	var original_palette_row_index := (
		G.settings.color_swap_original_palette_row_index
	)

	G.check(is_instance_valid(palettes))

	var image := palettes.get_image()

	var color_count := image.get_width()
	G.check(color_count <= _MAX_COLOR_COUNT)

	var palette_count := palettes.get_height()
	G.check(palette_count <= _MAX_PALETTE_COUNT)

	var original_palette: PackedInt32Array
	original_palette.resize(_MAX_COLOR_COUNT * 3)
	for i in color_count:
		var color := image.get_pixel(i, original_palette_row_index)
		original_palette[i * 3 + 0] = roundi(color.r * 255.0)
		original_palette[i * 3 + 1] = roundi(color.g * 255.0)
		original_palette[i * 3 + 2] = roundi(color.b * 255.0)

	var swap_palette: PackedVector3Array
	swap_palette.resize(_MAX_COLOR_COUNT * _MAX_PALETTE_COUNT)
	for y in palette_count:
		for x in color_count:
			var color := image.get_pixel(x, y)
			swap_palette[x + y * color_count] = Vector3(
				color.r, color.g, color.b)

	set_shader_parameter(&"color_count", color_count)
	set_shader_parameter(&"original_palette", original_palette)
	set_shader_parameter(&"swap_palette", swap_palette)
