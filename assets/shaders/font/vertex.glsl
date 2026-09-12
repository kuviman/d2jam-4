attribute vec2 a_pos;

varying vec2 v_uv;

uniform mat4 u_view_matrix;
uniform mat4 u_projection_matrix;
uniform mat4 u_model_matrix;
uniform vec2 u_uv_rect_pos;
uniform vec2 u_uv_rect_size;
uniform vec2 u_pos;

#define FIX_BLEEDING 0.99

void main() {
    vec2 local_uv = a_pos * FIX_BLEEDING * 0.5 + 0.5;
    v_uv = u_uv_rect_pos + local_uv * u_uv_rect_size;
    vec2 pos = local_uv + u_pos;
    gl_Position = u_projection_matrix * u_view_matrix * u_model_matrix * vec4(pos, 0.0, 1.0);
}
