shader_type spatial;
render_mode unshaded, blend_add, cull_disabled;

uniform vec4 color : source_color = vec4(1.0, 1.0, 0.5, 1.0);

void fragment() {
    ALBEDO = color.rgb;
    ALPHA = color.a;
}
