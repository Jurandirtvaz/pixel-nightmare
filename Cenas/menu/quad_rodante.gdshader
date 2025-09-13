shader_type canvas_item;

uniform sampler2D texture1 : source_color;
uniform sampler2D texture2 : source_color;
uniform sampler2D texture3 : source_color;
uniform sampler2D texture4 : source_color;

uniform float scroll_offset = 0.0;
uniform float zoom : hint_range(0.1, 5.0) = 1.0;

//calcula o resto da divisão de forma que funcione para números negativos.
float true_mod(float a, float b) {
	return a - b * floor(a / b);
}

void fragment() {
    vec2 zoomed_uv = (UV - vec2(0.5)) / zoom + vec2(0.5);
    zoomed_uv.x += scroll_offset;

    float total_width = 4.0;
    float scrolled_x = zoomed_uv.x * total_width;
    
    vec2 final_uv = vec2(fract(scrolled_x), zoomed_uv.y);
    
    float image_index = floor(true_mod(scrolled_x, total_width));

    vec4 final_color;
    if (image_index < 1.0) {
        final_color = texture(texture1, final_uv);
    } else if (image_index < 2.0) {
        final_color = texture(texture2, final_uv);
    } else if (image_index < 3.0) {
        final_color = texture(texture3, final_uv);
    } else {
        final_color = texture(texture4, final_uv);
    }
    
    COLOR = final_color;
}