attribute vec3 a_pos;
attribute vec2 a_uv;
attribute vec3 a_normal;

varying vec2 v_uv;
varying vec3 v_normal;

uniform mat4 u_model_matrix;
uniform mat4 u_view_matrix;
uniform mat4 u_projection_matrix;

void main() {
    v_uv = a_uv;
    v_normal = (u_model_matrix * vec4(a_normal, 0.0)).xyz;
    gl_Position = u_projection_matrix * u_view_matrix * u_model_matrix * vec4(a_pos, 1.0);
}
