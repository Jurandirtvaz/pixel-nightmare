shader_type canvas_item;

uniform float intensidade : hint_range(0.0, 1.0) = 1.0;
uniform float raio : hint_range(0.0, 1.0) = 0.35;
uniform vec3 cor_sangue = vec3(0.6, 0.0,0.0);

void fragment() {
	vec2 uv = UV;
	vec2 centro = vec2(0.5, 0.5);
	float distancia = distance(uv, centro);
	float borda = smoothstep(raio, 1.0, distancia);
	vec4 efeito = vec4(cor_sangue, borda * intensidade);

	COLOR = efeito;
}