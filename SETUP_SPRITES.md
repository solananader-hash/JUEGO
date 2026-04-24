# Guía de Configuración de Sprites

## Estructura de Carpetas Requerida

```
res://sprites/
└── gaucho/
    ├── idle/
    │   └── idle_1.png
    ├── walk/
    │   ├── walk_1.png
    │   ├── walk_2.png
    │   ├── walk_3.png
    │   ├── walk_4.png
    │   └── walk_5.png
    ├── dash/
    │   ├── dash_1.png
    │   └── dash_2.png
    └── attack/
        ├── attack_1.png
        └── attack_2.png
```

## Pasos para Agregar Sprites

1. **Crea las carpetas** en tu proyecto Godot:
   - Click derecho en `res://sprites/` → New Folder
   - Crea: `gaucho`, `gaucho/walk`, `gaucho/idle`, `gaucho/dash`, `gaucho/attack`

2. **Guarda los PNG**:
   - Los 5 frames de walk que compartiste van en `res://sprites/gaucho/walk/`
   - Nombra como: `walk_1.png`, `walk_2.png`, etc.

3. **Crea un sprite idle**:
   - Puedes copiar `walk_1.png` como `idle_1.png` en la carpeta `idle/`
   - O dibujar una pose en reposo

4. **Guarda el proyecto en Godot**:
   - File → Save (Ctrl+S)
   - Los sprites se cargarán automáticamente al ejecutar

## Configuración Automática

El script `AnimationLoader.gd` hace lo siguiente:

1. **Lee** todos los PNG de cada carpeta
2. **Ordena** los archivos alfabéticamente
3. **Crea animaciones** automáticamente con FPS=8
4. **Asigna** a AnimationPlayer

## Parámetros Configurables

En `scripts/player.gd`, línea ~30:

```gdscript
@export var animation_speed: float = 8  # FPS de las animaciones
```

Puedes cambiar esto para acelerar/ralentizar las animaciones.

## Formato de Sprites Recomendado

- **Dimensiones**: 128x128 o 256x256 píxeles
- **Formato**: PNG con transparencia (RGBA)
- **Estilo**: Mantener consistencia con rubber hose (bordes bien definidos, colores sólidos)
- **Pose**: Personaje centrado, mirando a la derecha (se flipea automáticamente)

## Troubleshooting

| Problema | Solución |
|----------|----------|
| "Animación no encontrada" | Verifica que los PNG estén en las carpetas correctas |
| Animación en blanco | El PNG no se cargó. Revisa permisos de carpeta |
| Animación muy lenta | Aumenta el FPS en `AnimationLoader` |
| Sprites fuera de lugar | Ajusta `offset` en Sprite2D (actualmente: -16 en Y) |

## Exportar desde Aseprite/Otros

Si usas Aseprite para animar:

1. File → Export Sprite Sheet
2. Selecciona "Individual frames" (no sheet)
3. Nombra como `walk_1.png`, `walk_2.png`, etc.
4. Copia a `res://sprites/gaucho/walk/`

¡Los sprites se cargarán automáticamente!
