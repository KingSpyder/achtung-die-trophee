shader_type canvas_item;

// Paramètres personnalisables
uniform vec4 color : source_color = vec4(1.0, 0.0, 0.0, 1.0);

void fragment() {
    // Coordonnées normalisées du fragment (entre 0 et 1)
    vec2 uv = UV;

    // Position des 3 sommets du triangle (en coordonnées normalisées)
    vec2 p0 = vec2(0.5, 0.1);
    vec2 p1 = vec2(0.1, 0.9);
    vec2 p2 = vec2(0.9, 0.9);

    // Calcul des barycentriques pour savoir si le point est dans le triangle
    float d0 = (uv.x - p1.x) * (p2.y - p1.y) - (uv.y - p1.y) * (p2.x - p1.x);
    float d1 = (uv.x - p2.x) * (p0.y - p2.y) - (uv.y - p2.y) * (p0.x - p2.x);
    float d2 = (uv.x - p0.x) * (p1.y - p0.y) - (uv.y - p0.y) * (p1.x - p0.x);

    bool is_inside = (d0 >= 0.0 && d1 >= 0.0 && d2 >= 0.0) ||
                     (d0 <= 0.0 && d1 <= 0.0 && d2 <= 0.0);

    if (is_inside) {
        COLOR.rgb = color.rgb;
    } else {
        discard;
    }
}
