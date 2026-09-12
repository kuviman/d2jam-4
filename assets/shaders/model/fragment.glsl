varying vec2 v_uv;
varying vec3 v_normal;
varying vec3 v_world_pos;

uniform sampler2D u_texture;

uniform vec3 u_player_pos;
uniform float u_player_radius;

vec4 lerp(vec4 a, vec4 b, float t) {
    return a * (1.0 - t) + b * t;
}

void main() {
    vec3 light_dir = normalize(vec3(2, 6, 7));
    float light_k = max(dot(light_dir, normalize(v_normal)), 0.0);
    float ambient_light = 0.8;
    light_k = ambient_light + light_k * (1.0 - ambient_light);
    float hightlight = 0.0;
    if (u_player_radius > 0.1) {
        float shadow_d = length(u_player_pos.xy - v_world_pos.xy);
        if (u_player_pos.z > v_world_pos.z && shadow_d < u_player_radius) {
            light_k -= 0.3;
        }
        float d = length(cross(v_normal, u_player_pos - v_world_pos));
        float hightlight_radius = 1.0;
        if (d < hightlight_radius && d > hightlight_radius - 0.1) {
            hightlight = 0.1;
        }
        if (length(u_player_pos - v_world_pos) > 2) {
            hightlight = 0.0;
        }
    }
    vec4 light_color = vec4(vec3(light_k), 1.0);
    gl_FragColor = texture2D(u_texture, v_uv) * light_color;
    gl_FragColor = lerp(gl_FragColor, vec4(1.0), hightlight);
}
