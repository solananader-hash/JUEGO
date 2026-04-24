extends Node

class_name DepthSorter

# Este script se encarga de actualizar el z_index de todos los objetos visibles
# basándose en su posición Y (greater Y = appears in front)

@export var update_frequency: float = 0.05

var timer: float = 0.0
var sortable_objects: Array[Node2D] = []

func _ready() -> void:
	# Buscar todos los nodos que deben ser ordenados por profundidad
	_collect_sortable_objects(get_parent())

func _process(delta: float) -> void:
	timer += delta
	if timer >= update_frequency:
		timer = 0.0
		_update_depth_order()

func _collect_sortable_objects(node: Node) -> void:
	if node is Node2D and node.is_in_group("depth_sortable"):
		sortable_objects.append(node)

	for child in node.get_children():
		_collect_sortable_objects(child)

func _update_depth_order() -> void:
	# Ordenar objetos por su posición Y (de menor a mayor)
	sortable_objects.sort_custom(func(a: Node2D, b: Node2D) -> bool:
		return a.global_position.y < b.global_position.y
	)

	# Asignar z_index basado en el orden
	for i in range(sortable_objects.size()):
		sortable_objects[i].z_index = i

func register_object(node: Node2D) -> void:
	if node not in sortable_objects:
		sortable_objects.append(node)
		node.add_to_group("depth_sortable")

func unregister_object(node: Node2D) -> void:
	sortable_objects.erase(node)
