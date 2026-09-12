attribute vec3 a_pos;
attribute vec2 a_uv;
attribute vec3 a_normal;

varying vec2 v_uv;
varying vec3 v_normal;
varying vec3 v_world_pos;
varying vec3 v_camera_normal;
varying vec3 v_camera_pos;

uniform mat4 u_model_matrix;
uniform mat4 u_view_matrix;
uniform mat4 u_projection_matrix;

void main() {
    v_uv = a_uv;
    v_normal = (u_model_matrix * vec4(a_normal, 0.0)).xyz;
    v_camera_normal = (u_view_matrix * vec4(v_normal, 0.0)).xyz;
    vec4 world_pos = u_model_matrix * vec4(a_pos, 1.0);
    v_world_pos = world_pos.xyz;
    vec4 camera_pos = u_view_matrix * world_pos;
    v_camera_pos = camera_pos.xyz;
    gl_Position = u_projection_matrix * camera_pos;
}
