extends Camera2D

class_name CameraController

@export var follow_speed: float = 5.0
@export var look_ahead_distance: float = 100.0
@export var vertical_offset: float = 0.0

var target_position: Vector2
var player: Player

func _ready() -> void:
	player = get_tree().get_first_child_in_group("player") as Player
	if player:
		target_position = player.global_position

func _process(delta: float) -> void:
	if not player:
		player = get_tree().get_first_child_in_group("player") as Player
		return

	# Calcular posición objetivo
	var player_pos = player.global_position
	var look_ahead = look_ahead_distance if player.facing_right else -look_ahead_distance

	target_position = Vector2(
		player_pos.x + look_ahead,
		player_pos.y + vertical_offset
	)

	# Suavizar movimiento de cámara
	global_position = global_position.lerp(target_position, follow_speed * delta)
