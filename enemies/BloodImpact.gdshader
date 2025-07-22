shader_type spatial;

render_mode unshaded, cull_disabled, depth_draw_opaque, blend_mix;

uniform vec4 blood_color : source_color = vec4(0.5, 0.0, 0.0, 1.0); // Dark red

void fragment() {
    // Posterize color
    vec3 color = floor(blood_color.rgb * 4.0) / 4.0;

    // Flicker effect
    float noise = fract(sin(dot(FRAGCOORD.xy, vec2(12.9898, 78.233))) * 43758.5453);
    float flicker = step(0.1, noise); // Lowered threshold so it's more visible

    ALBEDO = color * flicker;
    ALPHA = blood_color.a * flicker;
}
