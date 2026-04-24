extends Node

class_name GameManager

var player: Player
var depth_sorter: DepthSorter

func _ready() -> void:
	player = get_tree().get_first_child_in_group("player") as Player
	depth_sorter = get_node("DepthSorter") as DepthSorter

	if player:
		print("✓ Jugador cargado: ", player.name)
		print("  Posición: ", player.global_position)

		if player.animation_player:
			var animations = player.animation_player.get_animation_list()
			print("✓ Animaciones cargadas: ", animations.size())
			for anim in animations:
				print("  - ", anim)
		else:
			print("✗ AnimationPlayer no encontrado")

	if depth_sorter:
		print("✓ DepthSorter activo")
	else:
		print("✗ DepthSorter no encontrado")

	print("\n🎮 MALAMBO - Sistema listo")
	print("Controles:")
	print("  ↑↓←→ : Movimiento")
	print("  ESPACIO : Dash")
	print("  X : Ataque")

func _process(_delta: float) -> void:
	if Input.is_action_just_pressed("ui_cancel"):
		get_tree().quit()
