extends Node

class_name SpritePlaceholderGenerator

# Este script genera sprites placeholder si no tienes assets aún
# Útil para testear el juego sin gráficos finales

static func create_placeholder_sprite(size: Vector2 = Vector2(32, 64), color: Color = Color.WHITE) -> Texture2D:
	var image = Image.create(int(size.x), int(size.y), false, Image.FORMAT_RGBA8)
	image.fill(color)

	# Dibujar un rectángulo para simular el gaucho
	for x in range(int(size.x)):
		for y in range(int(size.y)):
			if x < 5 or x > size.x - 5 or y < 5 or y > size.y - 5:
				image.set_pixel(x, y, Color.BLACK)

	var texture = ImageTexture.create_from_image(image)
	return texture

static func create_gaucho_sprite() -> Texture2D:
	return create_placeholder_sprite(Vector2(32, 64), Color(0.8, 0.6, 0.4))

static func create_tree_sprite() -> Texture2D:
	return create_placeholder_sprite(Vector2(48, 80), Color(0.2, 0.6, 0.2))

static func create_ground_sprite() -> Texture2D:
	return create_placeholder_sprite(Vector2(64, 32), Color(0.6, 0.5, 0.3))
