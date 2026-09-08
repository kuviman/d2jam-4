use (import "lib/_lib.ks").*;
use (import "./assets.ks").*;
use (import "./model.ks").*;

module:

const Entity = newtype {
    .skin :: Int32,
    .pos :: Vec3,
    .rotation :: Angle,
    .rotation_axis :: Vec3,
};

const Game = newtype {
    .camera :: geng.Camera,
    .assets :: Assets.t,
    .model_renderer :: Model.Renderer,
    .entities :: ArrayList.t[Entity],
};

@eval (
    impl Game as geng.App = {
        .init = () => (
            let assets = Assets.load();
            let mut entities = ArrayList.new();
            for x in -2..3 do (
                for y in -2..3 do (
                    for z in -2..3 do (
                        let x = Int32_to_Float32(x);
                        let y = Int32_to_Float32(y);
                        let z = Int32_to_Float32(z);
                        let entity = {
                            .skin = std.random.gen_range(
                                .min = 0,
                                .max = ArrayList.length(&assets.models.skins),
                            ),
                            .pos = { x, y, z },
                            .rotation = Angle.from_degrees(0),
                            .rotation_axis = Vec3.normalize(
                                {
                                    std.random.gen_range(.min = -5, .max = +5),
                                    std.random.gen_range(.min = -5, .max = +5),
                                    5,
                                }
                            ),
                        };
                        &mut entities |> ArrayList.push_back(entity);
                    );
                );
            );
            {
                .camera = {
                    .pos = { 0, 0, 0 },
                    .distance = 5,
                    .attack = Angle.from_degrees(20),
                    .rotation = Angle.from_degrees(0),
                    .fov = Angle.from_degrees(90),
                },
                .assets,
                .model_renderer = Model.Renderer.init(),
                .entities,
            }
        ),
        .draw = self => (
            with Model.Renderer.Ctx = self^.model_renderer;
            with geng.CameraUniforms.Ctx = geng.CameraUniforms.init(
                self^.camera,
                .framebuffer_size = geng.get_window_size(),
            );
            ugli.clear({ 0.8, 0.8, 1, 1 });
            for entity in &self^.entities |> ArrayList.iter do (
                Model.draw(
                    self^.assets.models.skins.[entity^.skin],
                    Mat4.translate(entity^.pos)
                        |> Mat4.mul_mat(Mat4.rotate(entity^.rotation_axis, entity^.rotation))
                );
            );
        ),
        .update = (self, delta_time) => (
            self^.camera.rotation = Angle.from_degrees(
                Angle.degrees(self^.camera.rotation) + delta_time * 30
            );
            for entity in &mut self^.entities |> ArrayList.iter_mut do (
                entity^.rotation = Angle.add(
                    entity^.rotation,
                    Angle.from_degrees(30 * delta_time),
                );
            );
        ),
        .handle_event = (self, event) => (),
    }
);

geng.run[Game]();
