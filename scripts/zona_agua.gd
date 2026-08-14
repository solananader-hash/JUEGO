@tool
class_name ZonaAgua
extends Node2D

## Contenedor de todos los cuerpos de agua de una zona.
##
## Va instanciado una sola vez dentro de la escena de la zona. Sirve para:
##  - prender/apagar toda el agua de un saque (visibilidad, debug, performance)
##  - mover el conjunto sin tocar la zona
##  - tener un solo lugar donde ajustar el look global del agua de esa zona
##  - que la escena de la zona no se llene de 20 ColorRect sueltos

## Se aplica sobre TODOS los bloques hijos al entrar. Útil para que el agua de
## una zona de noche o de pantano se vea distinta sin duplicar la escena.
@export var tinte := Color.WHITE:
	set(v):
		tinte = v
		_aplicar_a_hijos()

## Multiplica la velocidad de todos los bloques. 0 = agua congelada.
@export_range(0.0, 3.0, 0.05) var velocidad_global: float = 1.0:
	set(v):
		velocidad_global = v
		_aplicar_a_hijos()

## Desincroniza los bloques entre sí variando levemente su velocidad según su
## posición, para que la zona no lata al unísono como una sola textura.
@export var desincronizar: bool = true:
	set(v):
		desincronizar = v
		_aplicar_a_hijos()


func _ready() -> void:
	_aplicar_a_hijos()


func _aplicar_a_hijos() -> void:
	if not is_inside_tree():
		return
	for hijo in get_children():
		var agua := hijo as BloqueAgua
		if agua == null:
			continue
		agua.modulate = tinte
		var jitter := 1.0
		if desincronizar:
			# Determinista: la misma posición da siempre el mismo desfasaje, así
			# el agua no cambia de aspecto entre corridas.
			jitter = 0.85 + fmod(absf(agua.position.x * 0.013 + agua.position.y * 0.029), 0.3)
		agua.velocidad_extra = velocidad_global * jitter


## Devuelve todos los bloques de agua de la zona. Útil desde el gameplay, por
## ejemplo para saber si el jugador está parado sobre agua.
func bloques() -> Array[BloqueAgua]:
	var lista: Array[BloqueAgua] = []
	for hijo in get_children():
		var agua := hijo as BloqueAgua
		if agua != null:
			lista.append(agua)
	return lista
