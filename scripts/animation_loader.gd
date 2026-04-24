extends Node

class_name AnimationLoader

# Carga sprites de carpetas y crea animaciones automáticamente

static func create_animation_from_sprites(animation_player: AnimationPlayer, anim_name: String, sprite_path: String, fps: int = 8, loop: bool = true) -> bool:
	var dir = DirAccess.open(sprite_path)
	if dir == null:
		push_error("No se encontró la carpeta: " + sprite_path)
		return false

	var sprite_files: Array[String] = []
	dir.list_dir_begin()
	var file_name = dir.get_next()

	# Recopilar archivos PNG
	while file_name != "":
		if file_name.ends_with(".png") and not file_name.begins_with("."):
			sprite_files.append(file_name)
		file_name = dir.get_next()

	# Ordenar archivos por nombre (importante para mantener orden de frames)
	sprite_files.sort()

	if sprite_files.is_empty():
		push_error("No hay sprites PNG en: " + sprite_path)
		return false

	var animation = Animation.new()
	var frame_duration = 1.0 / fps

	# Crear track para Sprite2D.texture
	var track_index = animation.add_track(Animation.TYPE_VALUE)
	animation.track_set_path(track_index, ".:texture")

	# Agregar cada sprite como un keyframe
	for i in range(sprite_files.size()):
		var sprite_full_path = sprite_path + "/" + sprite_files[i]
		var texture = load(sprite_full_path) as Texture2D

		if texture == null:
			push_error("No se pudo cargar: " + sprite_full_path)
			continue

		animation.track_insert_key(track_index, i * frame_duration, texture)

	# Configurar animación
	animation.length = sprite_files.size() * frame_duration
	if loop:
		animation.loop_mode = Animation.LOOP_LINEAR

	# Agregar a AnimationPlayer
	if animation_player.has_animation(anim_name):
		animation_player.remove_animation(anim_name)

	animation_player.add_animation(anim_name, animation)
	return true

static func load_all_animations(animation_player: AnimationPlayer, base_path: String = "res://sprites/gaucho") -> void:
	var animations = {
		"walk": base_path + "/walk",
		"idle": base_path + "/idle",
		"dash": base_path + "/dash",
		"attack": base_path + "/attack",
		"jump": base_path + "/jump"
	}

	for anim_name in animations.keys():
		var path = animations[anim_name]
		if DirAccess.open(path) != null:
			create_animation_from_sprites(animation_player, anim_name, path)
