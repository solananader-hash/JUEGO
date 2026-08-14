# Agua animada

Sistema para reemplazar los bloques celestes planos de las zonas por agua con
movimiento: olas cruzadas, destellos de sol, espuma en la orilla y contorno
negro irregular para que pegue con el estilo hand-painted del juego.

## Archivos

| Archivo | Qué es |
|---|---|
| `shaders/agua.gdshader` | El shader. Todo el movimiento vive acá. |
| `scenes/props/agua.tscn` | Un cuerpo de agua. Es lo que instanciás. |
| `scripts/agua.gd` | `BloqueAgua`: presets, escala del patrón, colisión. |
| `scenes/zonas/zona_1_agua.tscn` | Contenedor del agua de la zona 1. |
| `scripts/zona_agua.gd` | `ZonaAgua`: controla todos los bloques de una zona. |
| `scripts/tools/convertir_bloques_agua.gd` | Convierte los bloques que ya tenés. |

## ¿Por qué el agua va en otra escena?

Sí, conviene, por cuatro razones concretas:

1. **Un solo lugar para tocar el look.** Si el agua está suelta como 20
   ColorRect dentro de la zona, cambiar el celeste implica tocar 20 nodos. Con
   `agua.tscn` cambiás el `.tscn` una vez y se actualizan todos.
2. **La escena de la zona no se ensucia.** El árbol de la zona 1 pasa a tener un
   solo hijo `ZonaAgua` en vez de veinte rectángulos mezclados con las casas.
3. **Prendés y apagás el agua entera.** Para debug, para performance en
   máquinas lentas, o para una versión seca de la zona.
4. **Reusás en las otras zonas.** El río, la laguna y el mar de las zonas que
   vengan son la misma escena con otro preset.

La estructura queda así:

```
Zona1 (Node2D)
├── Suelo
├── ZonaAgua                 ← instancia de zona_1_agua.tscn
│   ├── Agua_Bloque1         ← instancias de agua.tscn
│   ├── Agua_Bloque2
│   └── ...
├── Aldea
└── Jugador
```

## Convertir los bloques que ya tenés

El conversor copia posición y tamaño exactos de tus bloques celestes, así no
tenés que rehacerlos a ojo.

1. Abrí en el editor la escena de la zona 1 (la de los bloques celestes).
2. Abrí `scripts/tools/convertir_bloques_agua.gd` en el editor de scripts.
3. **Archivo > Ejecutar** (`Ctrl+Shift+X`).
4. Mirá la consola de salida: lista cada bloque que detectó con su posición y
   tamaño, y no modifica nada todavía.
5. Si la lista tiene sentido, poné `SIMULAR = false` arriba del archivo y volvé
   a ejecutar.
6. Guardá la escena con `Ctrl+S`. **El conversor no guarda solo, y sus cambios
   no se deshacen con Ctrl+Z** — es un `EditorScript`, no pasa por el UndoRedo
   del editor. Si algo sale mal, cerrá la escena sin guardar.

Por defecto los bloques originales quedan **ocultos, no borrados**, para que
puedas comparar y volver atrás. Cuando estés conforme, borralos a mano o corré
de nuevo con `BORRAR_ORIGINALES = true`.

Si no detecta nada, el celeste de tus bloques no coincide con `COLOR_OBJETIVO`.
Clickeá un bloque, copiá su color del inspector, pegalo en la constante, o subí
`TOLERANCIA` de `0.28` a `0.4`.

## A mano

Arrastrá `scenes/props/agua.tscn` a la escena y estirá el rectángulo como
cualquier ColorRect. Se ve animado en el editor sin correr el juego.

## Ajustes

En cada bloque (inspector):

- **Estilo** — `LAGUNA` (el default, agua quieta), `RIO` (corriente marcada),
  `CHARCO` (chico y turbio), `MAR` (olas grandes), `PERSONALIZADO` (no pisa
  nada, editás los uniforms del material a mano).
- **Escala patrón** — cuántos píxeles ocupa una repetición de las olas. Es lo
  que hace que un bloque de 2000px y uno de 200px se vean del mismo material en
  vez de uno estirado y el otro comprimido. Bajalo para olas más chicas y
  detalladas.
- **Dirección flujo** — hacia dónde corre el agua. Solo se nota con `RIO`.
- **Velocidad extra** — multiplicador sobre el preset.
- **Bloquea paso** — crea un `StaticBody2D` en runtime para que el gaucho no
  camine sobre el agua. Apagalo si el agua es decorativa o si querés que se
  pueda vadear.

En el contenedor `ZonaAgua`:

- **Tinte** — tiñe toda el agua de la zona. Para una versión nocturna o de
  pantano sin duplicar escenas.
- **Velocidad global** — `0` congela toda el agua.
- **Desincronizar** — varía levemente la velocidad de cada bloque según su
  posición, para que la zona no lata al unísono como si fuera una sola textura.
  Es determinista: la misma posición da siempre el mismo desfasaje.

## Detalles de implementación que importan

**El material es `resource_local_to_scene`.** Sin eso, las instancias de
`agua.tscn` compartirían un único `ShaderMaterial` y se pisarían la
`escala_uv` entre sí: el último bloque en cargar le impondría su escala de olas
a todos los demás. El costo es que cada bloque tiene su propio material y no se
agrupan en un solo draw call, lo cual para una decena de cuerpos de agua no se
nota.

**`z_index = -5`.** El agua es suelo y tiene que quedar debajo de todo. Los
`Control` no participan del Y-sort de Godot, así que el orden se resuelve por
`z_index`, no por posición vertical. Si algún prop se dibuja por debajo del
agua, subí el `z_index` del prop en vez de bajar el del agua.

**`mouse_filter = IGNORE`.** Un `ColorRect` a pantalla completa se come los
clicks del jugador y de la UI si no se desactiva.

**Costo en GPU.** Son ~11 muestras de ruido por píxel. Sobre pocos bloques no
se nota, pero si llenás una zona entera de agua y baja el framerate, lo más
barato de recortar es bajar `escala_olas` y poner `brillo_destellos = 0`
(elimina una muestra de ruido por píxel).

## Sin verificar

El código no se pudo compilar ni correr: se escribió en un contenedor remoto
sin Godot instalado. Se revisó a mano contra la API de Godot 4.x y se verificó
que los nombres de los 19 uniforms coincidan entre shader, escena y script,
pero la primera corrida en el editor puede pedir algún ajuste.
