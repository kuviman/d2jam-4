use (import "../la.ks").*;

module:

const Camera = newtype {
    .pos :: Vec2,
    .fov :: Float32,
};

const CameraUniforms = newtype {
    .view_matrix :: Mat3,
    .projection_matrix :: Mat3,
};

const CameraCtx = @context CameraUniforms;

impl CameraUniforms as module = (
    module:

    const init = (
        camera :: Camera,
        .framebuffer_size :: Vec2,
    ) -> CameraUniforms => (
        let view_matrix = {
            { 1, 0, -camera.pos.0 },
            { 0, 1, -camera.pos.1 },
            { 0, 0, 1 },
        };
        let aspect = framebuffer_size.0 / framebuffer_size.1;
        let projection_matrix = {
            { 2 / aspect / camera.fov, 0, 0 },
            { 0, 2 / camera.fov, 0 },
            { 0, 0, 1 },
        };
        {
            .view_matrix,
            .projection_matrix,
        }
    );
);

impl Camera as module = (
    module:

    const screen_to_world = (
        camera :: Camera,
        screen_pos :: Vec2,
        .framebuffer_size :: Vec2,
    ) -> Vec2 => (
        let uniforms = CameraUniforms.init(camera, .framebuffer_size);
        let gl_screen_pos = Vec2.map(
            Vec2.vdiv(screen_pos, framebuffer_size),
            x => x * 2 - 1,
        );
        # projection_matrix * view_matrix * world_pos = gl_screen_pos
        let world_pos = Mat3.mul_vec(
            Mat3.inverse(
                Mat3.mul_mat(
                    uniforms.projection_matrix,
                    uniforms.view_matrix,
                )
            ),
            { gl_screen_pos.0, gl_screen_pos.1, 1 },
        );
        { world_pos.0, world_pos.1 }
    );
);
