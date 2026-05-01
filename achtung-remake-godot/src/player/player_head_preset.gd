class_name PlayerHeadPreset
extends Resource

const REFERENCE_SIZE: float = 50.0
const HEAD_COLOR: Color = Color(0.831, 0.831, 0.0, 1.0)

@export var head_texture: Texture2D
@export var collision_shape: Shape2D


func get_head_scale_for_size(target_size: float) -> Vector2:
	var safe_size := maxf(target_size, 0.01)
	var factor := safe_size / REFERENCE_SIZE
	return Vector2.ONE * factor


func build_collision_shape_for_size(target_size: float) -> Shape2D:
	if collision_shape == null:
		return null
	var safe_size := maxf(target_size, 0.01)
	var factor := 1.0 * safe_size
	var scaled_shape := collision_shape.duplicate()

	if scaled_shape is CircleShape2D:
		scaled_shape.radius *= factor / 2  #radius is half of size
	elif scaled_shape is RectangleShape2D:
		scaled_shape.size *= factor
	elif scaled_shape is CapsuleShape2D:
		scaled_shape.radius *= factor / 2  #radius is half of size
		scaled_shape.height *= factor

	return scaled_shape
