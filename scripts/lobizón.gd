extends Enemy

class_name Lobizon

# Jefe regional: El Lobizón (hombre lobo)
# Ubicación: Bosque oscuro
# Debilidad: Atrapar con boleadoras, luego atacar

@export var jump_force: float = -300.0
@export var jump_cooldown: float = 2.0
@export var rage_threshold: float = 0.3  # % salud para entrar en furia

var jump_timer: float = 0.0
var is_raging: bool = false

func _ready() -> void:
	enemy_name = "Lobizón"
	health = 50
	speed = 180.0
	patrol_range = 300.0
	detection_range = 400.0
	super()

func _physics_process(delta: float) -> void:
	if not is_alive:
		return

	jump_timer -= delta

	# Aplicar gravedad
	if not is_on_floor():
		velocity.y = minf(velocity.y + 800 * delta, 400)

	# Verificar si está en furia
	is_raging = float(current_health) / float(health) < rage_threshold

	# Detectar al jugador
	if player and is_player_detected():
		is_chasing = true
		_chase_player_aggressive()
	else:
		is_chasing = false
		_patrol()

	move_and_slide()

	# Actualizar animación basada en estado
	_update_animation()

func _chase_player_aggressive() -> void:
	var direction = sign(player.global_position.x - global_position.x)

	# Velocidad aumentada cuando está en furia
	var current_speed = speed * (1.5 if is_raging else 1.3)
	velocity.x = current_speed * direction

	# Saltar periódicamente
	if jump_timer <= 0 and is_on_floor():
		velocity.y = jump_force
		jump_timer = jump_cooldown
		if animation_player and animation_player.has_animation("jump"):
			animation_player.play("jump")

	# Actualizar sprite
	if sprite_2d:
		sprite_2d.flip_h = direction < 0

func _update_animation() -> void:
	if not animation_player:
		return

	if is_raging:
		if animation_player.has_animation("rage"):
			animation_player.play("rage")
	elif is_chasing:
		if animation_player.has_animation("chase"):
			animation_player.play("chase")
		elif animation_player.has_animation("walk"):
			animation_player.play("walk")
	else:
		if animation_player.has_animation("idle"):
			animation_player.play("idle")

func take_damage(damage: int) -> void:
	super.take_damage(damage)

	# Aumentar velocidad cuando recibe daño
	if is_alive and is_chasing:
		speed += 10

func die() -> void:
	print("¡%s ha sido derrotado!" % enemy_name)
	super.die()
