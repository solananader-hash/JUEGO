@tool
extends EditorScript

## Convierte los bloques celestes planos de una zona en agua animada.
##
## CÓMO SE USA
##   1. Abrí en el editor la escena de la zona (la que tiene los bloques celestes).
##   2. Abrí este archivo en el editor de scripts de Godot.
##   3. Menú Archivo > Ejecutar  (o Ctrl+Shift+X).
##   4. Mirá la consola de salida: lista lo que encontró y lo que hizo.
##
## Corré primero con SIMULAR = true para ver qué va a tocar sin que modifique
## nada. Si la lista tiene sentido, ponelo en false y volvé a ejecutar.

## Si es true no modifica nada: solo informa qué bloques detectó.
const SIMULAR := true

## Si es true borra los bloques celestes originales después de convertirlos.
## Con false los deja ocultos, por si querés volver atrás.
const BORRAR_ORIGINALES := false

## Color de los bloques a buscar. Es el celeste de la captura de la zona 1.
const COLOR_OBJETIVO := Color(0.18, 0.75, 0.87)

## Cuánto puede alejarse el color de un nodo del objetivo y aun así contar como
## agua. Subilo si tenés bloques en varios tonos de celeste.
const TOLERANCIA := 0.28

## Nombre del contenedor que se crea (o se reutiliza) dentro de la zona.
const NOMBRE_CONTENEDOR := "ZonaAgua"

const RUTA_AGUA := "res://scenes/props/agua.tscn"


func _run() -> void:
	var raiz := get_scene()
	if raiz == null:
		push_error("[agua] No hay ninguna escena abierta en el editor.")
		return

	var escena_agua := load(RUTA_AGUA) as PackedScene
	if escena_agua == null:
		push_error("[agua] No se pudo cargar %s" % RUTA_AGUA)
		return

	var candidatos: Array[Node] = []
	_buscar(raiz, candidatos)

	if candidatos.is_empty():
		print("[agua] No encontré bloques del color objetivo en '%s'." % raiz.name)
		print("[agua] Probá subir TOLERANCIA o ajustar COLOR_OBJETIVO al celeste real.")
		return

	print("[agua] %d bloque(s) detectado(s) en '%s':" % [candidatos.size(), raiz.name])
	for n in candidatos:
		print("        %s  pos=%s  tam=%s" % [
			raiz.get_path_to(n), _posicion_de(n), _tamano_de(n)])

	if SIMULAR:
		print("[agua] SIMULAR = true, no toqué nada. Poné SIMULAR = false para aplicar.")
		return

	var contenedor := _obtener_contenedor(raiz)

	var convertidos := 0
	for original in candidatos:
		var agua := escena_agua.instantiate()
		agua.name = "Agua_" + str(original.name)
		agua.position = _posicion_de(original)
		agua.size = _tamano_de(original)
		contenedor.add_child(agua)
		agua.owner = raiz

		if BORRAR_ORIGINALES:
			original.get_parent().remove_child(original)
			original.queue_free()
		elif original is CanvasItem:
			(original as CanvasItem).visible = false
		convertidos += 1

	print("[agua] Listo: %d bloque(s) convertido(s) dentro de '%s'." % [
		convertidos, NOMBRE_CONTENEDOR])
	if not BORRAR_ORIGINALES:
		print("[agua] Los originales quedaron ocultos, no borrados. Revisá y borralos vos.")
	print("[agua] Acordate de guardar la escena (Ctrl+S).")


func _buscar(nodo: Node, salida: Array[Node]) -> void:
	for hijo in nodo.get_children():
		# No re-convertir agua ya creada.
		# Node.name es un StringName: lo paso por str() antes de tratarlo como texto.
		if hijo is BloqueAgua or str(hijo.name).begins_with("Agua_"):
			continue
		if _es_bloque_celeste(hijo):
			salida.append(hijo)
		else:
			_buscar(hijo, salida)


func _es_bloque_celeste(nodo: Node) -> bool:
	var color: Color
	if nodo is ColorRect:
		color = (nodo as ColorRect).color
	elif nodo is Polygon2D:
		color = (nodo as Polygon2D).color
	elif nodo is Sprite2D:
		# Un Sprite2D teñido de celeste (placeholder sin textura propia).
		color = (nodo as Sprite2D).modulate
	else:
		return false

	# Distancia en RGB. Ignoramos alpha a propósito: un bloque semitransparente
	# sigue siendo el mismo bloque.
	var d := Vector3(
		color.r - COLOR_OBJETIVO.r,
		color.g - COLOR_OBJETIVO.g,
		color.b - COLOR_OBJETIVO.b).length()
	return d <= TOLERANCIA


func _posicion_de(nodo: Node) -> Vector2:
	# El agua es un Control: su `position` es la esquina superior izquierda.
	# Un ColorRect ya usa ese mismo criterio, pero un Sprite2D centrado usa su
	# centro, así que hay que correrlo media caja para que no quede desplazado.
	if nodo is ColorRect:
		return (nodo as ColorRect).position
	if nodo is Sprite2D:
		var s := nodo as Sprite2D
		if s.centered:
			return s.position - _tamano_de(s) * 0.5
		return s.position
	if nodo is Node2D:
		return (nodo as Node2D).position
	if nodo is Control:
		return (nodo as Control).position
	return Vector2.ZERO


func _tamano_de(nodo: Node) -> Vector2:
	if nodo is ColorRect:
		return (nodo as ColorRect).size
	if nodo is Polygon2D:
		var poly := (nodo as Polygon2D).polygon
		if poly.size() >= 2:
			var r := Rect2(poly[0], Vector2.ZERO)
			for p in poly:
				r = r.expand(p)
			return r.size
	if nodo is Sprite2D:
		var s := nodo as Sprite2D
		if s.texture != null:
			return s.texture.get_size() * s.scale
		return s.scale
	return Vector2(256, 256)


func _obtener_contenedor(raiz: Node) -> Node2D:
	var existente := raiz.find_child(NOMBRE_CONTENEDOR, true, false)
	if existente is Node2D:
		print("[agua] Reutilizo el contenedor '%s' que ya existía." % NOMBRE_CONTENEDOR)
		return existente as Node2D

	var contenedor := Node2D.new()
	contenedor.name = NOMBRE_CONTENEDOR
	contenedor.set_script(load("res://scripts/zona_agua.gd"))
	raiz.add_child(contenedor)
	contenedor.owner = raiz
	print("[agua] Creé el contenedor '%s'." % NOMBRE_CONTENEDOR)
	return contenedor
