@tool
class_name BloqueAgua
extends ColorRect

## Un cuerpo de agua animado. Reemplaza a los bloques celestes planos.
##
## Se usa instanciando `res://scenes/props/agua.tscn` y arrastrando el tamaño
## en el editor, igual que un ColorRect comun. El shader se actualiza en vivo
## gracias a @tool, asi que lo ves moverse sin correr el juego.

enum Estilo {
	LAGUNA,   ## agua quieta, celeste claro (el default de la zona 1)
	RIO,      ## corriente marcada en una direccion
	CHARCO,   ## chico, turbio, poco movimiento
	MAR,      ## profundo, olas grandes, mucha espuma
	PERSONALIZADO, ## no toca los parametros: los editas a mano en el material
}

## Preset de agua. Cambiarlo pisa velocidad/color/olas con valores coherentes.
@export var estilo: Estilo = Estilo.LAGUNA:
	set(v):
		estilo = v
		_aplicar()

## Cuántos píxeles del mundo ocupa una repetición del patrón de olas.
## Es lo que hace que un bloque de 2000px y uno de 200px se vean del mismo
## "material" en vez de uno estirado y el otro comprimido.
@export_range(32.0, 1024.0, 1.0) var escala_patron: float = 256.0:
	set(v):
		escala_patron = v
		_aplicar()

## Dirección de la corriente. Solo se nota con el estilo RIO.
@export var direccion_flujo := Vector2(1.0, 0.6):
	set(v):
		direccion_flujo = v
		_aplicar()

## Multiplicador sobre la velocidad del preset, para desincronizar bloques
## vecinos y que no latan todos al mismo tiempo.
@export_range(0.0, 3.0, 0.05) var velocidad_extra: float = 1.0:
	set(v):
		velocidad_extra = v
		_aplicar()

@export_group("Colisión")

## Si está activo, crea un StaticBody2D en runtime para que el jugador no pueda
## caminar sobre el agua.
@export var bloquea_paso: bool = true

## Capa de física del cuerpo generado (por defecto la 1, igual que las paredes).
@export_flags_2d_physics var capa_colision: int = 1

var _cuerpo: StaticBody2D
var _forma: CollisionShape2D


func _ready() -> void:
	# El agua es suelo: nunca debe comerse los clicks del jugador ni de la UI.
	mouse_filter = Control.MOUSE_FILTER_IGNORE
	_aplicar()
	if Engine.is_editor_hint():
		return
	if bloquea_paso:
		_crear_colision()


func _notification(que: int) -> void:
	if que == NOTIFICATION_RESIZED:
		_aplicar()
		if is_instance_valid(_forma):
			_ajustar_colision()


func _aplicar() -> void:
	var mat := material as ShaderMaterial
	if mat == null:
		return

	# El patrón de olas se escala con el tamaño real del bloque en píxeles,
	# no con su UV, así todos los cuerpos de agua comparten la misma textura.
	mat.set_shader_parameter("escala_uv", size / maxf(escala_patron, 1.0))
	mat.set_shader_parameter("direccion_flujo", direccion_flujo)

	if estilo == Estilo.PERSONALIZADO:
		return

	var p := _preset(estilo)
	mat.set_shader_parameter("velocidad", float(p["velocidad"]) * velocidad_extra)
	mat.set_shader_parameter("escala_olas", p["escala_olas"])
	mat.set_shader_parameter("fuerza_olas", p["fuerza_olas"])
	mat.set_shader_parameter("bandas", p["bandas"])
	mat.set_shader_parameter("ancho_espuma", p["ancho_espuma"])
	mat.set_shader_parameter("brillo_destellos", p["brillo_destellos"])
	mat.set_shader_parameter("color_profundo", p["color_profundo"])
	mat.set_shader_parameter("color_medio", p["color_medio"])
	mat.set_shader_parameter("color_superficie", p["color_superficie"])


func _preset(e: Estilo) -> Dictionary:
	match e:
		Estilo.RIO:
			return {
				"velocidad": 0.85, "escala_olas": 5.5, "fuerza_olas": 0.045,
				"bandas": 5.0, "ancho_espuma": 0.10, "brillo_destellos": 0.5,
				"color_profundo": Color(0.063, 0.318, 0.443),
				"color_medio": Color(0.129, 0.565, 0.694),
				"color_superficie": Color(0.435, 0.831, 0.898),
			}
		Estilo.CHARCO:
			return {
				"velocidad": 0.18, "escala_olas": 7.0, "fuerza_olas": 0.018,
				"bandas": 4.0, "ancho_espuma": 0.14, "brillo_destellos": 0.25,
				"color_profundo": Color(0.153, 0.294, 0.310),
				"color_medio": Color(0.259, 0.482, 0.482),
				"color_superficie": Color(0.478, 0.702, 0.671),
			}
		Estilo.MAR:
			return {
				"velocidad": 0.50, "escala_olas": 3.0, "fuerza_olas": 0.055,
				"bandas": 6.0, "ancho_espuma": 0.12, "brillo_destellos": 0.6,
				"color_profundo": Color(0.020, 0.216, 0.376),
				"color_medio": Color(0.063, 0.451, 0.639),
				"color_superficie": Color(0.325, 0.784, 0.878),
			}
		_: # LAGUNA
			return {
				"velocidad": 0.35, "escala_olas": 4.0, "fuerza_olas": 0.035,
				"bandas": 5.0, "ancho_espuma": 0.07, "brillo_destellos": 0.45,
				"color_profundo": Color(0.043, 0.361, 0.514),
				"color_medio": Color(0.106, 0.573, 0.729),
				"color_superficie": Color(0.400, 0.831, 0.914),
			}


func _crear_colision() -> void:
	_cuerpo = StaticBody2D.new()
	_cuerpo.name = "CuerpoAgua"
	_cuerpo.collision_layer = capa_colision
	_cuerpo.collision_mask = 0
	_forma = CollisionShape2D.new()
	_forma.shape = RectangleShape2D.new()
	_cuerpo.add_child(_forma)
	add_child(_cuerpo)
	_ajustar_colision()


func _ajustar_colision() -> void:
	var rect := _forma.shape as RectangleShape2D
	rect.size = size
	# El origen de un Control es su esquina superior izquierda; el de una forma
	# de colisión es su centro.
	_forma.position = size * 0.5
