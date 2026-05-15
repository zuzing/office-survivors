shader_type canvas_item;

uniform vec4 hitflash_color = vec4(1.0, 1.0, 1.0, 1.0);
uniform bool hit_flash_on = false;

void vertex() {
	// Called for every vertex the material is visible on.
}

void fragment() {
	// Called for every pixel the material is visible on.
	vec4 sprite_color = texture(TEXTURE, UV);
	vec3 final_rgb = hit_flash_on ? hitflash_color.rgb : sprite_color.rgb;
	COLOR = vec4(final_rgb, sprite_color.a);
}

//void light() {
//	// Called for every pixel for every light affecting the CanvasItem.
//	// Uncomment to replace the default light processing function with this one.
//}
