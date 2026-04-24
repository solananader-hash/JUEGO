# 🎮 MALAMBO - Guía Rápida

## Instalación y Ejecución

### 1. **Abre el proyecto en Godot**
```bash
godot -e .
```

### 2. **Ejecuta el juego**
- Click en el botón ▶️ (Play) en la esquina superior derecha
- O presiona `F5`

### 3. **Verifica la consola**
La consola debe mostrar:
```
✓ Jugador cargado: Player
  Posición: (720, 600)
✓ Animaciones cargadas: 5
  - idle
  - walk
  - dash
  - attack
  - jump
✓ DepthSorter activo

🎮 MALAMBO - Sistema listo
Controles:
  ↑↓←→ : Movimiento
  ESPACIO : Dash
  X : Ataque
```

## Controles

| Tecla | Acción |
|-------|--------|
| `↑↓←→` | Movimiento (arriba/abajo = profundidad) |
| `ESPACIO` | Dash (deslizada con poncho) |
| `X` | Ataque (facón) |
| `ESC` | Salir |

## Qué Esperar

1. **Pantalla negra con el gaucho** en el centro
2. **Presiona flechas** para moverte
3. **El gaucho gira** cuando cambias dirección (flip horizontal)
4. **Las animaciones se reproduce**: idle → walk cuando te mueves
5. **Prueba el dash**: Presiona ESPACIO para deslizar rápido
6. **Profundidad 2.5D**: Sube (↑) para ir "hacia atrás", baja (↓) para ir "hacia delante"

## Características Activas

- ✅ Movimiento 2.5D (X, Y, profundidad)
- ✅ Cámara que sigue al personaje
- ✅ Animaciones automáticas (idle, walk, dash)
- ✅ Sistema de dash con cooldown
- ✅ Depth sorting (Z-index automático)
- ✅ Gravity y colisiones

## Troubleshooting

### "Animación no encontrada"
- Verifica que los PNG estén en: `res://sprites/gaucho/{animation_name}/`
- Nombres deben ser: `idle_1.png`, `walk_1.png`, `walk_2.png`, etc.

### "Sprite en blanco o no se ve"
- Abre el Inspector (esquina derecha)
- Selecciona el Player
- En Sprite2D → Texture, debería mostrar la imagen cargada

### "No se mueve"
- Verifica que el CollisionShape2D esté visible en el árbol de nodos
- Prueba con WASD en lugar de flechas

## Próximos Pasos

Una vez que confirmes que todo funciona:

1. **Crear enemigos**: Lobizón, Luz Mala, Pombero
2. **Sistema de combate**: Facón + boleadoras
3. **Minijuegos**: Truco (duelo de cartas)
4. **Mapa de provincias**: Supramundo de viaje
5. **Sistema de tienda**: Mejoras en la pulpería

---

**¿Algún problema?** Revisa la consola de Godot (Output → Console) para mensajes de error.
