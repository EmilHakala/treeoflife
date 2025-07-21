shader_type spatial;
render_mode unshaded, cull_disabled, depth_draw_never;

uniform vec4 flash_color : source_color = vec4(1.0, 0.8, 0.2, 1.0);
uniform float noise_strength = 0.3;
uniform float flash_speed = 10.0;
uniform float pixelation = 64.0; // Lower = chunkier

float rand(vec2 co) {
    return fract(sin(dot(co.xy ,vec2(12.9898,78.233))) * 43758.5453);
}

void fragment() {
    // Pixelate UVs
    vec2 pixel_uv = floor(UV * pixelation) / pixelation;

    // Animate noise flash
    float t = TIME * flash_speed;
    float n = rand(pixel_uv + vec2(t, t));
    
    float flash_intensity = step(0.5, n) * noise_strength;
    
    ALBEDO = flash_color.rgb + flash_intensity;
    ALPHA = flash_color.a * step(0.4, n); // flickery
}
