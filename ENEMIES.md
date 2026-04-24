# 👹 Sistema de Enemigos y Jefes

## Arquitectura

Todos los enemigos heredan de `Enemy.gd` que proporciona:
- Patrullaje automático
- Detección del jugador
- Persecución
- Sistema de daño y muerte
- Integración con depth sorting

## Jefes Regionales (Del GDD)

### 1. **Lobizón** (Bosque Oscuro)
- **Tipo**: Combate ágil y rápido
- **Mecánica**: Saltos rápidos, persecución agresiva
- **Debilidad**: Ralentización con boleadoras
- **Recompensa**: Amuleto Lobo (aumenta velocidad)

```gdscript
# Uso
var lobizon = preload("res://scenes/enemies/lobizon.tscn").instantiate()
add_child(lobizon)
lobizon.global_position = Vector2(500, 400)
```

### 2. **Luz Mala** (Pampa Nocturna)
- **Tipo**: Puzzle/evasión
- **Mecánica**: Luz flotante, requiere espejos para reflejar
- **Debilidad**: Luz reflectada con espejos
- **Recompensa**: Brújula Mágica

*Script próximo: `luz_mala.gd`*

### 3. **Pombero** (Humedal)
- **Tipo**: Duelo de ingenio
- **Mecánica**: Minijuego de Truco
- **Debilidad**: Ganar 2 manos de Truco
- **Recompensa**: Tabaco Bendito (regenera vida)

*Script próximo: `pombero.gd`*

## Crear tu Propio Enemigo

### Paso 1: Crear el Script

```gdscript
# scripts/mi_enemigo.gd
extends Enemy

class_name MiEnemigo

func _ready() -> void:
    enemy_name = "Mi Enemigo"
    health = 30
    speed = 120.0
    super()

func _physics_process(delta: float) -> void:
    # Tu lógica personalizada aquí
    super._physics_process(delta)

func _chase_player() -> void:
    # Sobrescribir comportamiento de persecución
    super._chase_player()
    # Tu lógica aquí
```

### Paso 2: Crear la Escena

1. Copia `scenes/enemies/enemy_template.tscn`
2. Renombra como `mi_enemigo.tscn`
3. Asigna tu script en el nodo raíz
4. Configura parámetros en el Inspector

### Paso 3: Agregar Sprites

```
res://sprites/enemigos/mi_enemigo/
├── idle/
│   └── idle_1.png
├── walk/
│   ├── walk_1.png
│   └── walk_2.png
├── chase/
│   ├── chase_1.png
│   └── chase_2.png
└── die/
    └── die_1.png
```

El script automáticamente cargará las animaciones con:
```gdscript
AnimationLoader.load_all_animations(animation_player, "res://sprites/enemigos/mi_enemigo")
```

## Parámetros Exportados

| Parámetro | Tipo | Descripción |
|-----------|------|-------------|
| `enemy_name` | String | Nombre del enemigo |
| `health` | int | Puntos de vida |
| `speed` | float | Velocidad de movimiento |
| `patrol_range` | float | Distancia que patrulla |
| `detection_range` | float | Radio de detección del jugador |

## Métodos Principales

### `take_damage(damage: int)`
```gdscript
# Causar daño
lobizon.take_damage(10)
```

### `die()`
```gdscript
# Matar enemigo
lobizon.die()
```

### `is_player_detected() -> bool`
```gdscript
if lobizon.is_player_detected():
    print("¡El jugador fue detectado!")
```

## Estados del Enemigo

1. **Patrullaje**: Se mueve en rango predefinido
2. **Persecución**: Sigue al jugador cuando lo detecta
3. **Ataque**: *Próximo: Sistema de ataque*
4. **Muerte**: Reproduce animación y se elimina

## Comportamientos Avanzados

### Jefe con Fase 2

```gdscript
extends Lobizon

var phase: int = 1

func take_damage(damage: int) -> void:
    super.take_damage(damage)
    
    if phase == 1 and current_health <= health / 2:
        phase = 2
        speed *= 1.5
        print("¡Lobizón entra en FURIA!")
```

### Enemigo que Salta a Posiciones Aleatorias

```gdscript
extends Enemy

func _chase_player() -> void:
    if randf() > 0.7:  # 30% de probabilidad
        velocity.y = -400  # Saltar
    super._chase_player()
```

### Enemigo que Regenera Vida

```gdscript
var regeneration: int = 1

func _physics_process(delta: float) -> void:
    super._physics_process(delta)
    
    if not is_chasing:
        current_health = mini(current_health + int(regeneration * delta), health)
```

## Integración con el Jugador

El sistema de enemigos se comunica con el jugador para:
- Detectarlo (distancia)
- Recibir daño (cuando es golpeado)
- Morir (cuando pierde toda la vida)

```gdscript
# En el script del jugador
if enemy.is_player_detected():
    # El enemigo vio al jugador
    pass

# Cuando atacas un enemigo
enemy.take_damage(player_attack_damage)
```

## Próximos Pasos

1. ✅ Sistema base de enemigos (Enemy.gd)
2. ✅ Lobizón (jefe regional ejemplo)
3. ⏳ Luz Mala (jefe puzzle)
4. ⏳ Pombero (jefe minijuego)
5. ⏳ Sistema de ataque del jugador
6. ⏳ Colisiones ataque-enemigo

---

**Nota**: Los enemigos se posicionan automáticamente en el depth sorting según su Y.
