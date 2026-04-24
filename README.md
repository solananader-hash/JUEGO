# MALAMBO - Juego de Exploración 2.5D

Juego de exploración y acción 2D con temática argentina, estilo "rubber hose" y folklore nativo.

## Requisitos del Proyecto

- **Motor**: Godot 4.1+
- **Resolución**: 1440x2560 (9:16 vertical)
- **Lenguaje**: GDScript

## Estructura del Proyecto

```
JUEGO/
├── scenes/
│   ├── main.tscn (Escena principal)
│   └── player/ (Escenas del jugador)
├── scripts/
│   ├── player.gd (Lógica de movimiento)
│   ├── camera_controller.gd (Sistema de cámara)
│   └── depth_sorter.gd (Ordenamiento por profundidad)
├── sprites/ (Archivos de sprite)
├── sounds/ (Música y efectos)
└── project.godot (Configuración del proyecto)
```

## Características Implementadas

### 1. Sistema de Movimiento 2.5D
- Movimiento horizontal (izquierda/derecha)
- Movimiento vertical/profundidad (arriba/abajo del escenario)
- Física con gravedad y colisiones
- Aceleración y fricción suave

### 2. Cámara Lateral Inteligente
- Sigue al personaje con suavizado
- Look-ahead (anticipa movimiento del personaje)
- Ajuste vertical para mejor composición visual

### 3. Depth Sorting (Z-Index Automático)
- Ordena sprites automáticamente por su posición Y
- Garantiza que el gaucho pase detrás de árboles cuando sube
- Aparece enfrente cuando baja

### 4. Sistema de Dash
- Deslizada rápida usando el poncho
- Cooldown entre usos
- Recupera dirección del último input

### 5. Control de Entrada
- `↑↓←→` o Analógico: Movimiento
- `ESPACIO` o Joypad: Dash
- `X` o Click izquierdo: Ataque

## Próximos Pasos

1. **Crear sprites del gaucho** (idle, walk, dash, attack)
2. **Implementar sistema de animaciones** con AnimationPlayer
3. **Agregar enemigos y jefes** (Lobizón, Luz Mala, Pombero)
4. **Sistema de combate** (facón + boleadoras)
5. **Minijuegos** (Truco, sapo, taba)
6. **Sistema de diálogos** y encuentros culturales
7. **Tienda de pulpería** para mejorar equipo
8. **Mapa de provincias** (supramundo)

## Cómo Agregar Sprites

1. Coloca los archivos PNG en `res://sprites/`
2. Crea nuevas AnimationPlayer en la escena del jugador
3. Usa `animation_player.play("animation_name")` en el script

Ejemplo con sprite sheet:
```gdscript
var sprite_texture = load("res://sprites/gaucho_walk.png")
var animation = Animation.new()
# Configurar frames de la animación...
```

## Comandos para Compilar

```bash
# Abrir el editor de Godot
godot -e .

# Exportar juego
godot --export HTML5 build/malambo.html
```

## Notas de Diseño

- El gaucho es el centro de la experiencia
- La profundidad 2.5D crea sensación de exploración orgánica
- Los jefes deben aprovechar la mecánica de profundidad
- Cada región debe sentirse distintiva visual y musicalmente
