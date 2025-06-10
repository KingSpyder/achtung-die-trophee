shader_type canvas_item;

uniform float radius :hint_range(0, 1) = 0.5;
uniform vec4 circle_color : source_color = vec4(1);
uniform float elipse_factor :hint_range(0, 90) = 45;

void vertex() {
	// Called for every vertex the material is visible on.
}

void fragment() {
	vec2 uv = UV * 2.0 - 1.0;

	float ef = radians(elipse_factor);
	uv.x *= cos(ef);
	uv.y *= sin(ef);

	float circle = ceil(length(uv) - radius);
	circle = 1. - circle;
	circle = clamp(circle, 0, circle_color.a);

	COLOR = circle_color;
	COLOR.a = circle;
}

//void light() {
//	// Called for every pixel for every light affecting the CanvasItem.
//	// Uncomment to replace the default light processing function with this one.
//}
