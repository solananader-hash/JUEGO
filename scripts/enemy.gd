extends CharacterBody2D

class_name Enemy

@export var enemy_name: String = "Enemigo"
@export var health: int = 30
@export var speed: float = 100.0
@export var patrol_range: float = 200.0
@export var detection_range: float = 300.0

var current_health: int
var is_alive: bool = true
var player: Player
var is_chasing: bool = false
var patrol_direction: int = 1
var patrol_start_x: float

@onready var sprite_2d = $Sprite2D
@onready var animation_player = $AnimationPlayer
@onready var collision_shape_2d = $CollisionShape2D

func _ready() -> void:
	current_health = health
	player = get_tree().get_first_child_in_group("player") as Player
	patrol_start_x = global_position.x
	add_to_group("depth_sortable")

	if animation_player:
		if animation_player.has_animation("idle"):
			animation_player.play("idle")

func _physics_process(delta: float) -> void:
	if not is_alive:
		return

	# Aplicar gravedad
	if not is_on_floor():
		velocity.y = minf(velocity.y + 800 * delta, 400)

	# Detectar al jugador
	if player and is_player_detected():
		is_chasing = true
		_chase_player()
	else:
		is_chasing = false
		_patrol()

	move_and_slide()

func is_player_detected() -> bool:
	if not player:
		return false
	var distance = global_position.distance_to(player.global_position)
	return distance < detection_range

func _patrol() -> void:
	velocity.x = speed * patrol_direction

	# Cambiar dirección si alcanza el límite
	if abs(global_position.x - patrol_start_x) > patrol_range:
		patrol_direction *= -1

	# Actualizar sprite
	if sprite_2d:
		sprite_2d.flip_h = patrol_direction < 0

	# Reproducir animación
	if animation_player and animation_player.has_animation("walk"):
		animation_player.play("walk")

func _chase_player() -> void:
	var direction = sign(player.global_position.x - global_position.x)
	velocity.x = speed * direction * 1.5

	# Actualizar sprite
	if sprite_2d:
		sprite_2d.flip_h = direction < 0

	# Reproducir animación
	if animation_player and animation_player.has_animation("chase"):
		animation_player.play("chase")
	elif animation_player and animation_player.has_animation("walk"):
		animation_player.play("walk")

func take_damage(damage: int) -> void:
	if not is_alive:
		return

	current_health -= damage
	print("%s recibió %d de daño. Salud: %d/%d" % [enemy_name, damage, current_health, health])

	if current_health <= 0:
		die()

func die() -> void:
	is_alive = false
	velocity = Vector2.ZERO

	if animation_player and animation_player.has_animation("die"):
		animation_player.play("die")
	else:
		_remove_enemy()

func _remove_enemy() -> void:
	queue_free()

func get_depth_position() -> float:
	return global_position.y
