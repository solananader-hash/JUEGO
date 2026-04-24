extends Node

class_name DebugAnimation

# Script de debug para testear animaciones sin todos los sprites

static func create_placeholder_animation(animation_player: AnimationPlayer, anim_name: String, frame_count: int = 4) -> void:
	if animation_player.has_animation(anim_name):
		return

	var animation = Animation.new()
	var frame_duration = 0.1

	var track_index = animation.add_track(Animation.TYPE_VALUE)
	animation.track_set_path(track_index, ".:modulate")

	# Crear efecto de parpadeo para simular animación
	var colors = [Color.WHITE, Color(0.8, 0.8, 0.8), Color.WHITE]
	for i in range(frame_count):
		var color = colors[i % colors.size()]
		animation.track_insert_key(track_index, i * frame_duration, color)

	animation.length = frame_count * frame_duration
	animation.loop_mode = Animation.LOOP_LINEAR

	animation_player.add_animation(anim_name, animation)

static func setup_debug_animations(animation_player: AnimationPlayer) -> void:
	# Crear animaciones placeholder para testing
	create_placeholder_animation(animation_player, "idle", 2)
	create_placeholder_animation(animation_player, "walk", 4)
	create_placeholder_animation(animation_player, "dash", 3)
	create_placeholder_animation(animation_player, "attack", 3)
