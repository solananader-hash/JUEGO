extends CharacterBody2D

class_name Player

# Movimiento
@export var speed: float = 200.0
@export var acceleration: float = 800.0
@export var friction: float = 500.0
@export var gravity: float = 800.0
@export var max_fall_speed: float = 400.0
@export var jump_force: float = -400.0

# Velocidad vertical (profundidad 2.5D)
@export var depth_speed: float = 150.0

# Dash
@export var dash_speed: float = 400.0
@export var dash_duration: float = 0.3
@export var dash_cooldown: float = 0.5

var is_dashing: bool = false
var dash_timer: float = 0.0
var dash_cooldown_timer: float = 0.0
var dash_direction: Vector2 = Vector2.ZERO

var is_grounded: bool = false
var facing_right: bool = true

@onready var sprite_2d = $Sprite2D
@onready var collision_shape_2d = $CollisionShape2D
@onready var animation_player = $AnimationPlayer

func _ready() -> void:
	# Cargar animaciones desde sprites
	if animation_player:
		AnimationLoader.load_all_animations(animation_player)
		if animation_player.has_animation("idle"):
			animation_player.play("idle")
		else:
			push_warning("Animación 'idle' no encontrada. Asegúrate de tener sprites en res://sprites/gaucho/")

func _physics_process(delta: float) -> void:
	# Manejar entrada
	var input_vector = Input.get_vector("ui_left", "ui_right", "ui_up", "ui_down")

	# Actualizar dash
	if dash_cooldown_timer > 0:
		dash_cooldown_timer -= delta

	# Iniciar dash
	if Input.is_action_just_pressed("dash") and dash_cooldown_timer <= 0 and not is_dashing:
		_start_dash(input_vector)

	# Actualizar dash
	if is_dashing:
		_update_dash(delta)
	else:
		# Movimiento normal
		_handle_movement(input_vector, delta)

	# Aplicar gravedad
	if not is_on_floor():
		velocity.y = minf(velocity.y + gravity * delta, max_fall_speed)
	else:
		is_grounded = true
		if velocity.y > 0:
			velocity.y = 0

	# Detectar si está en el suelo
	is_grounded = is_on_floor()

	# Aplicar velocidad
	move_and_slide()

	# Actualizar sprite basado en dirección
	_update_sprite_direction(input_vector)

func _handle_movement(input_vector: Vector2, delta: float) -> void:
	# Movimiento horizontal (izquierda/derecha)
	if input_vector.x != 0:
		velocity.x = move_toward(velocity.x, input_vector.x * speed, acceleration * delta)
	else:
		velocity.x = move_toward(velocity.x, 0, friction * delta)

	# Movimiento vertical (profundidad 2.5D - arriba/abajo del escenario)
	if input_vector.y != 0:
		velocity.z = input_vector.y * depth_speed
	else:
		velocity.z = move_toward(velocity.z if velocity.has("z") else 0, 0, friction * delta)

func _start_dash(input_vector: Vector2) -> void:
	is_dashing = true
	dash_timer = dash_duration
	dash_cooldown_timer = dash_duration + dash_cooldown

	# Usar dirección de entrada o dirección actual
	if input_vector.length() > 0:
		dash_direction = input_vector.normalized()
	else:
		dash_direction = Vector2.RIGHT if facing_right else Vector2.LEFT

	# Reproducir animación de dash si existe
	if animation_player and animation_player.has_animation("dash"):
		animation_player.play("dash")

func _update_dash(delta: float) -> void:
	dash_timer -= delta

	if dash_timer <= 0:
		is_dashing = false
		return

	velocity.x = dash_direction.x * dash_speed
	velocity.z = dash_direction.y * dash_speed if velocity.has("z") else 0

func _update_sprite_direction(input_vector: Vector2) -> void:
	if input_vector.x > 0:
		facing_right = true
		sprite_2d.flip_h = false
	elif input_vector.x < 0:
		facing_right = false
		sprite_2d.flip_h = true

	# Actualizar animación
	if animation_player:
		if is_dashing:
			if animation_player.has_animation("dash"):
				animation_player.play("dash")
		elif input_vector.length() > 0:
			if animation_player.has_animation("walk"):
				animation_player.play("walk")
		else:
			if animation_player.has_animation("idle"):
				animation_player.play("idle")

func get_depth_position() -> float:
	return position.y

func is_moving() -> bool:
	return velocity.length() > 0 or is_dashing
