// agua.gdshader — agua animada estilo hand-painted (Godot 4.x)
//
// Pensado para reemplazar los bloques celestes planos de las zonas.
// Se aplica sobre cualquier nodo con UV en 0..1 (ColorRect, MeshInstance2D con
// QuadMesh, Sprite2D con textura). El script agua.gd ajusta `escala_uv`
// automáticamente segun el tamaño del bloque para que el patron de olas tenga
// la misma escala en un charco chico que en una laguna grande.

shader_type canvas_item;
render_mode blend_mix;

// ── Paleta ───────────────────────────────────────────────────────────────────
uniform vec4 color_profundo   : source_color = vec4(0.043, 0.361, 0.514, 1.0);
uniform vec4 color_medio      : source_color = vec4(0.106, 0.573, 0.729, 1.0);
uniform vec4 color_superficie : source_color = vec4(0.400, 0.831, 0.914, 1.0);
uniform vec4 color_espuma     : source_color = vec4(0.886, 0.976, 1.000, 1.0);
uniform vec4 color_contorno   : source_color = vec4(0.055, 0.114, 0.157, 1.0);
uniform float opacidad : hint_range(0.0, 1.0) = 1.0;

// ── Movimiento ───────────────────────────────────────────────────────────────
uniform float velocidad       : hint_range(0.0, 2.0)  = 0.35;
uniform float escala_olas     : hint_range(0.5, 20.0) = 4.0;
uniform float fuerza_olas     : hint_range(0.0, 0.2)  = 0.035;
uniform vec2  direccion_flujo = vec2(1.0, 0.6);
uniform vec2  escala_uv = vec2(1.0, 1.0);

// ── Estilo ───────────────────────────────────────────────────────────────────
// Cantidad de bandas de color. Valores bajos (3-5) dan el look pintado a mano
// con manchas planas; valores altos (20+) dan un degradado suave y realista.
uniform float bandas          : hint_range(2.0, 32.0) = 5.0;
uniform float brillo_destellos: hint_range(0.0, 1.0)  = 0.45;
uniform float umbral_destellos: hint_range(0.5, 1.0)  = 0.80;

// ── Orilla ───────────────────────────────────────────────────────────────────
uniform float ancho_espuma      : hint_range(0.0, 0.4)  = 0.07;
uniform float ancho_contorno    : hint_range(0.0, 0.1)  = 0.012;
uniform float irregularidad     : hint_range(0.0, 3.0)  = 1.2;
uniform float pulso_espuma      : hint_range(0.0, 1.0)  = 0.4;

float hash(vec2 p) {
	return fract(sin(dot(p, vec2(127.1, 311.7))) * 43758.5453123);
}

float ruido(vec2 p) {
	vec2 i = floor(p);
	vec2 f = fract(p);
	vec2 u = f * f * (3.0 - 2.0 * f);
	return mix(
		mix(hash(i + vec2(0.0, 0.0)), hash(i + vec2(1.0, 0.0)), u.x),
		mix(hash(i + vec2(0.0, 1.0)), hash(i + vec2(1.0, 1.0)), u.x),
		u.y);
}

// 3 octavas: suficiente detalle para el look pintado, barato en GPU.
float fbm(vec2 p) {
	float v = 0.0;
	float a = 0.5;
	for (int i = 0; i < 3; i++) {
		v += a * ruido(p);
		p *= 2.03;
		a *= 0.5;
	}
	return v;
}

void fragment() {
	vec2 uv = UV * escala_uv;
	float t = TIME * velocidad;
	vec2 flujo = normalize(direccion_flujo + vec2(0.0001)) * t;

	// --- Dos capas de olas cruzadas que distorsionan el muestreo -------------
	float ola_a = fbm(uv * escala_olas + flujo);
	float ola_b = fbm(uv * escala_olas * 1.7 - flujo.yx * 0.8);
	vec2 uvd = uv + vec2(ola_a - 0.5, ola_b - 0.5) * fuerza_olas * escala_olas;

	// --- Altura de la superficie: ruido + un tren de olas direccional --------
	float altura = fbm(uvd * escala_olas * 0.9 + flujo * 0.5);
	float tren = sin(dot(uvd, normalize(direccion_flujo + vec2(0.0001))) * 6.0 + t * 2.2) * 0.5 + 0.5;
	altura = mix(altura, tren, 0.35);

	// --- Posterizado: manchas planas de color, no degradado --------------- --
	float h = floor(altura * bandas) / max(bandas - 1.0, 1.0);

	vec3 col = mix(color_profundo.rgb, color_medio.rgb, smoothstep(0.0, 0.6, h));
	col = mix(col, color_superficie.rgb, smoothstep(0.55, 1.0, h));

	// --- Destellos del sol sobre las crestas ---------------------------------
	float chispa = ruido(uvd * escala_olas * 3.4 + vec2(-t * 1.3, t * 0.9));
	col += step(umbral_destellos, chispa) * brillo_destellos;

	// --- Orilla: espuma y contorno negro irregular ---------------------------
	// Distancia normalizada al borde mas cercano del bloque.
	vec2 d = min(UV, vec2(1.0) - UV) * max(escala_uv, vec2(0.0001));
	float borde = min(d.x, d.y) / max(min(escala_uv.x, escala_uv.y), 0.0001);

	// El ruido rompe la linea recta del rectangulo para que no se vea como una caja.
	float sacudida = (fbm(uv * escala_olas * 2.0 + flujo * 0.4) - 0.5) * irregularidad * ancho_espuma;

	// smoothstep con edge0 == edge1 es indefinido: si el ancho es 0 el agua
	// parpadea en el borde. Piso mínimo para que nunca se igualen.
	float espuma = 1.0 - smoothstep(0.0, max(ancho_espuma, 0.0005), borde + sacudida);
	espuma *= 1.0 - pulso_espuma + pulso_espuma * (sin(t * 3.0 + (uv.x + uv.y) * 8.0) * 0.5 + 0.5);
	col = mix(col, color_espuma.rgb, clamp(espuma, 0.0, 1.0) * 0.85);

	float contorno = 1.0 - smoothstep(0.0, max(ancho_contorno, 0.0005), borde + sacudida * 0.45);
	col = mix(col, color_contorno.rgb, clamp(contorno, 0.0, 1.0));

	// COLOR entra con el color/modulate del nodo: conservamos su alpha para que
	// `modulate` siga funcionando desde el inspector y desde los Tween.
	COLOR = vec4(col, opacidad * COLOR.a);
}
