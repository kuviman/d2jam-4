varying vec2 v_uv;
varying vec3 v_normal;

uniform sampler2D u_texture;

vec4 lerp(vec4 a, vec4 b, float t) {
    return a * (1.0 - t) + b * t;
}

void main() {
    vec3 light_dir = normalize(vec3(2, 6, 7));
    float light_k = max(dot(light_dir, normalize(v_normal)), 0.0);
    float ambient_light = 0.8;
    vec4 shadow_color = vec4(ambient_light, ambient_light, ambient_light, 1.0);
    vec4 light_color = lerp(shadow_color, vec4(1.0, 1.0, 1.0, 1.0), light_k);
    gl_FragColor = texture2D(u_texture, v_uv) * light_color;
}
