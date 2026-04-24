#!/usr/bin/env python3
"""
Genera sprites placeholder para testing del juego MALAMBO
Crea PNGs simples con formas geométricas que simulan al gaucho
"""

from PIL import Image, ImageDraw
import os

def create_gaucho_sprite(filename, pose="idle"):
    """Crea un sprite placeholder del gaucho"""
    width, height = 128, 192
    img = Image.new('RGBA', (width, height), (0, 0, 0, 0))
    draw = ImageDraw.Draw(img)

    # Sombrero
    draw.ellipse([30, 10, 98, 35], fill=(101, 67, 33), outline=(0, 0, 0), width=2)
    draw.polygon([(20, 35), (108, 35), (100, 28), (28, 28)], fill=(101, 67, 33))

    # Cabeza
    draw.ellipse([35, 30, 93, 65], fill=(139, 90, 43), outline=(0, 0, 0), width=2)

    # Barba
    draw.ellipse([45, 50, 83, 65], fill=(50, 30, 15), outline=(0, 0, 0), width=1)

    # Ojos
    draw.ellipse([45, 40, 52, 48], fill=(0, 0, 0))
    draw.ellipse([76, 40, 83, 48], fill=(0, 0, 0))

    # Poncho (parte superior)
    points_poncho = [(25, 60), (103, 60), (110, 110), (18, 110)]
    draw.polygon(points_poncho, fill=(139, 101, 58), outline=(0, 0, 0), width=2)

    # Sol en el poncho (característica del gaucho)
    center = (64, 85)
    radius = 15
    draw.ellipse([center[0]-radius, center[1]-radius, center[0]+radius, center[1]+radius],
                 fill=(255, 200, 0), outline=(0, 0, 0), width=1)
    for angle in range(0, 360, 45):
        import math
        rad = math.radians(angle)
        x1 = center[0] + radius * math.cos(rad)
        y1 = center[1] + radius * math.sin(rad)
        x2 = center[0] + (radius + 8) * math.cos(rad)
        y2 = center[1] + (radius + 8) * math.sin(rad)
        draw.line([(x1, y1), (x2, y2)], fill=(255, 200, 0), width=2)

    # Brazos y manos (varían según pose)
    if pose == "idle":
        # Brazos relajados
        draw.rectangle([20, 70, 30, 120], fill=(139, 90, 43), outline=(0, 0, 0), width=1)
        draw.rectangle([98, 70, 108, 120], fill=(139, 90, 43), outline=(0, 0, 0), width=1)
    elif pose == "walk":
        # Brazos en movimiento
        draw.polygon([(20, 75), (25, 90), (35, 85), (30, 70)], fill=(139, 90, 43))
        draw.polygon([(108, 90), (100, 110), (110, 115), (118, 100)], fill=(139, 90, 43))
    elif pose == "dash":
        # Brazos atrás por el dash
        draw.polygon([(15, 80), (20, 95), (30, 92), (25, 77)], fill=(139, 90, 43))
        draw.polygon([(98, 80), (108, 77), (118, 92), (113, 95)], fill=(139, 90, 43))

    # Piernas (varían según pose)
    if pose == "idle":
        draw.rectangle([45, 110, 55, 180], fill=(79, 62, 43), outline=(0, 0, 0), width=1)
        draw.rectangle([73, 110, 83, 180], fill=(79, 62, 43), outline=(0, 0, 0), width=1)
    elif pose == "walk":
        # Pierna izquierda adelante
        draw.polygon([(45, 110), (50, 110), (48, 155), (43, 155)], fill=(79, 62, 43))
        # Pierna derecha atrás
        draw.polygon([(75, 110), (83, 120), (80, 175), (72, 165)], fill=(79, 62, 43))
    elif pose == "dash":
        # Piernas estiradas
        draw.polygon([(40, 110), (48, 115), (50, 170), (42, 165)], fill=(79, 62, 43))
        draw.polygon([(80, 110), (88, 115), (90, 170), (82, 165)], fill=(79, 62, 43))

    # Botas
    draw.ellipse([40, 175, 60, 190], fill=(50, 35, 20), outline=(0, 0, 0), width=1)
    draw.ellipse([68, 175, 88, 190], fill=(50, 35, 20), outline=(0, 0, 0), width=1)

    return img

def generate_all_sprites():
    """Genera todos los sprites necesarios"""
    base_path = "/home/user/JUEGO/sprites/gaucho"

    animations = {
        "idle": ["idle"],
        "walk": ["walk"] * 4,  # 4 frames de walk
        "dash": ["dash"] * 2,   # 2 frames de dash
        "attack": ["idle"],     # Placeholder
        "jump": ["idle"]        # Placeholder
    }

    for anim_name, poses in animations.items():
        folder = os.path.join(base_path, anim_name)
        os.makedirs(folder, exist_ok=True)

        for i, pose in enumerate(poses, 1):
            img = create_gaucho_sprite(f"{anim_name}_{i}.png", pose=pose)
            filepath = os.path.join(folder, f"{anim_name}_{i}.png")
            img.save(filepath)
            print(f"✓ Creado: {filepath}")

if __name__ == "__main__":
    try:
        generate_all_sprites()
        print("\n✓ Sprites placeholder generados exitosamente")
        print("Puedes reemplazarlos con tus PNG cuando estén listos")
    except Exception as e:
        print(f"Error: {e}")
