shader_type canvas_item;

uniform sampler2D SCREEN_TEXTURE : hint_screen_texture;

uniform int color_count;
uniform ivec3[32] original_palette;
uniform vec3[256] swap_palette;

uniform int swap_index;

void fragment() {
	// Sample from the screen texture to get the actual rendered scene
	vec4 screen_color = texture(SCREEN_TEXTURE, SCREEN_UV);
	ivec3 colori = ivec3(round(screen_color.rgb * 255.0));

	// Apply palette swapping
	COLOR = screen_color;
	for (int i = 0; i < color_count; i++) {
		if (colori == original_palette[i]) {
			COLOR.rgb = swap_palette[i + swap_index * color_count];
			break;
		}
	}
}