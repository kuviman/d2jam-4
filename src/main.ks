use (import "lib/_lib.ks").*;
use (import "./assets.ks").*;
use (import "./model.ks").*;

const interop = import "./interop.ks";
const client = import "./client.ks";
const collisions = import "./collisions.ks";

module:

const Entity = newtype {
    .skin :: Int32,
    .position :: Vec3,
    .velocity :: Vec3,
    .rotation :: Quat,
    .angular_velocity :: Vec3,
    .can_jump :: Bool,
};

impl Entity as module = (
    module:

    const draw = (entity :: &Entity) => (
        let assets = @current Assets.Ctx;
        Model.draw(
            assets.models.skins.[entity^.skin],
            Mat4.translate(entity^.position)
                |> Mat4.mul_mat(Quat.into_mat4(entity^.rotation))
        );
    );
);

const OtherPlayer = newtype {
    .skin :: Int32,
    .position :: Vec3,
    .rotation :: Angle,
};

impl OtherPlayer as module = (
    module:

    const draw = (entity :: &OtherPlayer) => (
        let assets = @current Assets.Ctx;
        Model.draw(
            assets.models.skins.[entity^.skin],
            Mat4.translate(Vec3.add(entity^.position, { 0, 0, 1 }))
                |> Mat4.mul_mat(Mat4.rotate_z(entity^.rotation))
        );
    );
);

const Game = newtype {
    .camera :: geng.Camera,
    .assets :: Assets.t,
    .model_renderer :: Model.Renderer,
    .ground :: Model.t,
    .player :: Entity,
    .other_players :: OrdMap.t[interop.Id, OtherPlayer],
    .jetpack_enabled :: Bool,
};

const handle_mmo = (self :: &mut Game) => (
    while client.poll_message() is :Some msg do (
        match msg with (
            | :Connected id => (
                print("Connected " + to_string(id));
                let player = {
                    .skin = 1,
                    .position = { 0, 0, 0 },
                    .rotation = Angle.from_degrees(0),
                };
                &mut self^.other_players |> OrdMap.add(id, player);
            )
            | :Disconnected id => (
                print("Disconnected " + to_string(id));
                &mut self^.other_players |> OrdMap.remove(id);
            )
            | :UpdatePlayer { .id, .state } => (
                print("Updated " + to_string(id));
                let player = &mut self^.other_players
                    |> OrdMap.get_mut(id)
                    |> Option.unwrap;
                player^.position = state.position;
            )
            | :RequestUpdate => (
                print("Update requested");
                client.send(:Update { .position = self^.player.position });
            )
        )
    );
);

@eval (
    impl Game as geng.App = {
        .init = () => (
            SDL.SetWindowRelativeMouseMode((@current geng.Context).window, true);
            let assets = Assets.load();
            let ground = (
                let mut v :: Vec2 = Vec2.mul({ 1, -1 }, 100);
                let mut vs = ArrayList.new();
                for (_ :: Int32) in 0..4 do (
                    &mut vs |> ArrayList.push_back(v);
                    v = { -v.1, v.0 };
                );
                let vertex = i => {
                    .a_pos = { ...vs.[i], 0 },
                    .a_uv = vs.[i],
                    .a_normal = { 0, 0, 1 },
                };
                let mut data = ArrayList.new();
                &mut data |> ArrayList.push_back(vertex(0));
                &mut data |> ArrayList.push_back(vertex(1));
                &mut data |> ArrayList.push_back(vertex(2));
                &mut data |> ArrayList.push_back(vertex(0));
                &mut data |> ArrayList.push_back(vertex(2));
                &mut data |> ArrayList.push_back(vertex(3));
                {
                    .texture = assets.textures.ground,
                    .buffer = ugli.VertexBuffer.init(&data),
                }
            );
            {
                .camera = {
                    .position = { 0, 0, 5 },
                    .distance = 5,
                    .attack = Angle.from_degrees(30),
                    .rotation = Angle.from_degrees(0),
                    .fov = Angle.from_degrees(90),
                },
                .assets,
                .ground,
                .model_renderer = Model.Renderer.init(),
                .player = {
                    .position = { 0, 0, 10 },
                    .velocity = { 0, 0, 0 },
                    .rotation = Quat.IDENTITY,
                    .angular_velocity = { 0, 0, 0 },
                    .skin = 0,
                    .can_jump = false,
                },
                .other_players = OrdMap.new(),
                .jetpack_enabled = false,
            }
        ),
        .draw = self => (
            with Assets.Ctx = self^.assets;
            with Model.Renderer.Ctx = self^.model_renderer;
            with geng.CameraUniforms.Ctx = geng.CameraUniforms.init(
                self^.camera,
                .framebuffer_size = geng.get_window_size(),
            );
            ugli.clear({ 0.8, 0.8, 1, 1 });
            Model.draw(self^.assets.models.level.model, Mat4.IDENTITY);
            Model.draw(self^.assets.models.skins.[1], Mat4.translate({ 10, 0, 1 }));
            Entity.draw(&self^.player);
            for &{ .key = _, .value = ref other_player } in &self^.other_players |> OrdMap.iter do (
                OtherPlayer.draw(other_player);
            );
        ),
        .update = (self, delta_time) => (
            let delta_time = min(delta_time, 0.050);
            # handle_mmo(self);
            let mut wasd :: Vec2 = { 0, 0 };
            if geng.input.Key.is_pressed(:W) or geng.input.Key.is_pressed(:ArrowUp) then (
                wasd.0 += 1;
            );
            if geng.input.Key.is_pressed(:A) or geng.input.Key.is_pressed(:ArrowLeft) then (
                wasd.1 += 1;
            );
            if geng.input.Key.is_pressed(:S) or geng.input.Key.is_pressed(:ArrowDown) then (
                wasd.0 -= 1;
            );
            if geng.input.Key.is_pressed(:D) or geng.input.Key.is_pressed(:ArrowRight) then (
                wasd.1 -= 1;
            );
            let player_speed = 15;
            let player_acceleration = 20;
            if self^.jetpack_enabled then (
                let target_velocity :: Vec3 = {
                    ...Vec2.rotate(
                        Vec2.mul(Vec2.normalize_or_zero(wasd), player_speed),
                        self^.camera.rotation,
                    ),
                    (
                        let mut z = 0;
                        if geng.input.Key.is_pressed(:Space) then (
                            z += 1;
                        );
                        if geng.input.Key.is_pressed(:LeftShift) then (
                            z -= 1;
                        );
                        z * player_speed
                    ),
                };
                self^.player.velocity = Vec3.add(
                    self^.player.velocity,
                    Vec3.mul(
                        Vec3.sub(target_velocity, self^.player.velocity),
                        min(player_acceleration * delta_time, 1),
                    ),
                );
            ) else (
                if self^.player.can_jump and geng.input.Key.is_pressed(:Space) then (
                    self^.player.velocity.2 += 20;
                );
                let gravity = 50;
                self^.player.velocity.2 -= gravity * delta_time;
            );

            let max_angular_velocity = 10;
            let target_angular_velocity = Vec3.mul(
                { ...Vec2.rotate_90(Vec2.rotate(wasd, self^.camera.rotation)), 0 },
                max_angular_velocity,
            );
            let angular_acceleration = 10;
            self^.player.angular_velocity = Vec3.add(
                self^.player.angular_velocity,
                Vec3.mul(
                    Vec3.sub(target_angular_velocity, self^.player.angular_velocity),
                    min(angular_acceleration * delta_time, 1),
                ),
            );
            self^.player.rotation = Quat.add(
                self^.player.rotation,
                Quat.mul(
                    Quat.mul_quat(
                        (
                            let { i, j, k } = self^.player.angular_velocity;
                            { .i, .j, .k, .w = 0 }
                        ),
                        self^.player.rotation,
                    ),
                    delta_time / 2,
                )
            )
                |> Quat.normalize;
            self^.player.position = Vec3.add(
                self^.player.position,
                Vec3.mul(self^.player.velocity, delta_time),
            );
            self^.player.can_jump = collisions.collide_and_react(
                .position = &mut self^.player.position,
                .velocity = &mut self^.player.velocity,
                .angular_velocity = &mut self^.player.angular_velocity,
                .radius = 1,
                .mesh = &self^.assets.models.level.collision_mesh,
            );
            self^.camera.position = Vec3.add(self^.player.position, { 0, 0, 3 });
        ),
        .handle_event = (self, event) => (
            match event with (
                | :KeyPress :F => (
                    self^.jetpack_enabled = not self^.jetpack_enabled;
                )
                | :MouseMove { .delta, ... } => (
                    let degree_per_pixel :: Float32 = 360 / 2000;
                    self^.camera.rotation = Angle.sub(
                        self^.camera.rotation,
                        Angle.from_degrees(delta.0 * degree_per_pixel),
                    );
                    self^.camera.attack = Angle.from_degrees(
                        clamp(
                            Angle.degrees(self^.camera.attack)
                            - delta.1 * degree_per_pixel,
                            .min = -90,
                            .max = 90,
                        )
                    );
                )
                | _ => ()
            );
        ),
    }
);

const cli = import "./cli.ks";

let args = cli.parse();
@comment_out (
if args.server is :Some address then (
    const server = import "./server.ks";
    let run = () => server.run(address);
    match args.connect with (
        | :None => (
            run();
        )
        | :Some _ => (
            std.thread.spawn(run);
        )
    );
);
);
if args.connect is :Some address then (
    # let c = client.connect(address);
    # with client.Ctx = c;
    geng.run[Game]();
);
