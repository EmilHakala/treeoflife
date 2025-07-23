shader_type canvas_item;

uniform float rotation_deg = 0.0;

void fragment() {
    float angle = -radians(rotation_deg - 130.0);

    vec2 center = vec2(0.5);
    vec2 uv = UV - center;

    float cos_angle = cos(angle);
    float sin_angle = sin(angle);

    vec2 rotated_uv = vec2(
        cos_angle * uv.x - sin_angle * uv.y,
        sin_angle * uv.x + cos_angle * uv.y
    );

    uv = rotated_uv + center;

    // If uv is outside bounds, make it transparent
    if (uv.x < 0.0 || uv.x > 1.0 || uv.y < 0.0 || uv.y > 1.0) {
        discard;
    }

    COLOR = texture(TEXTURE, uv);
}
