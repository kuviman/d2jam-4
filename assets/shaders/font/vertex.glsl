precision highp float;

attribute vec2 a_pos;

varying vec2 v_uv;

uniform mat3 u_view_matrix;
uniform mat3 u_projection_matrix;
uniform vec2 u_uv_rect_pos;
uniform vec2 u_uv_rect_size;
uniform vec2 u_pos;
uniform vec2 u_size;

#define FIX_BLEEDING 0.99

void main() {
    vec2 local_uv = a_pos * FIX_BLEEDING * 0.5 + 0.5;
    v_uv = u_uv_rect_pos + local_uv * u_uv_rect_size;
    vec2 pos = local_uv * u_size + u_pos;
    vec3 screen_pos = u_projection_matrix * u_view_matrix * vec3(pos, 1.0);
    gl_Position = vec4(screen_pos.xy, 0.0, screen_pos.z);
}