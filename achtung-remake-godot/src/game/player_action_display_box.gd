class_name PlayerActionDisplayBox
extends HBoxContainer

const ICON_SIZE := Vector2(18, 18)


func update_display(token_textures: Array) -> void:
	for child in get_children():
		child.queue_free()

	for token_texture in token_textures:
		if token_texture == null or not (token_texture is Texture2D):
			continue
		var icon := TextureRect.new()
		icon.texture = token_texture
		icon.custom_minimum_size = ICON_SIZE
		icon.stretch_mode = TextureRect.STRETCH_KEEP_ASPECT_CENTERED
		add_child(icon)
