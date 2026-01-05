//Based on 2D outline shader 1.0.0; Julian-Vos; MIT; 2024-04-01
//https://godotengine.org/asset-library/asset/2829

shader_type canvas_item;
render_mode blend_mix;

uniform vec4 color : source_color = vec4(1.0);
uniform float width : hint_range(0, 100) = 1.0;

varying flat vec4 modulate;

// CUSTOM
uniform bool enabled = false;
uniform float pulse_frequency : hint_range(0, 100) = 10.0;
// CUSTOM

void vertex() {
	// CUSTOM
	if(enabled) {
	// CUSTOM
		modulate = COLOR;
	}
}

bool hasContraryNeighbour(vec2 uv, vec2 tex_size, sampler2D tex) {
    for (int x = -int(width); x <= int(width); x++) {
        for (int y = -int(width); y <= int(width); y++) {
            vec2 offset = uv + vec2(float(x), float(y)) * tex_size;

            // If neighbor is outside the texture, treat as transparent
            if (offset.x < 0.0 || offset.x > 1.0 || offset.y < 0.0 || offset.y > 1.0) {
                return true;
            }

            // Otherwise, check alpha
            if (texture(tex, clamp(offset, 0.0, 1.0)).a <= 0.0) {
                return true;
            }
        }
    }
    return false;
}


void fragment() {
	// CUSTOM
	if(enabled) {
	// CUSTOM
		vec2 uv = UV;

		COLOR = texture(TEXTURE, uv) * modulate;

		if (COLOR.a > 0.0 && hasContraryNeighbour(uv, TEXTURE_PIXEL_SIZE, TEXTURE)) {
			COLOR.rgb = mix(COLOR.rgb, color.rgb * modulate.rgb, color.a * modulate.a);
			//CUSTOM
			//COLOR.a += (1.0 - COLOR.a) * color.a * modulate.a;
			COLOR.a = clamp(sin(TIME * pulse_frequency)/2.0 + 1.0, 0.0, 1.0);
			//CUSTOM
		}
	}
}
