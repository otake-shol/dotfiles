// Bloom shader for Ghostty
// Adds a subtle glow effect to bright pixels

void mainImage(out vec4 fragColor, in vec2 fragCoord) {
    vec2 uv = fragCoord / iResolution.xy;

    // Get the original color
    vec4 color = texture(iChannel0, uv);

    // Simple bloom effect - sample surrounding pixels
    float blur_size = 0.003;
    vec4 bloom = vec4(0.0);

    for (float x = -2.0; x <= 2.0; x += 1.0) {
        for (float y = -2.0; y <= 2.0; y += 1.0) {
            vec2 offset = vec2(x, y) * blur_size;
            bloom += texture(iChannel0, uv + offset);
        }
    }
    bloom /= 25.0;

    // Blend original with bloom
    float bloom_intensity = 0.3;
    fragColor = color + bloom * bloom_intensity;
    fragColor.a = color.a;
}
