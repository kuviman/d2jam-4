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
    .scale :: Float32,
};

const MIN_SCALE = 1;
const MAX_SCALE = 2;

const MAX_SPEED = 50;

impl Entity as module = (
    module:

    const draw = (entity :: &Entity, .jetpack :: Bool) => (
        let assets = @current Assets.Ctx;
        Model.draw(
            assets.models.skins.[entity^.skin],
            Mat4.translate(entity^.position)
                |> Mat4.mul_mat(Mat4.scale_uniform(entity^.scale))
                |> Mat4.mul_mat(Quat.into_mat4(entity^.rotation)),
        );
        if jetpack then (
            let angle = Angle.from_degrees(1000 * geng.time_since_start());
            Model.draw(
                assets.models.jetpack,
                Mat4.translate(entity^.position)
                    |> Mat4.mul_mat(Mat4.rotate_z(angle)),
            );
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
    .water :: Model.t,
    .player :: Entity,
    .other_players :: OrdMap.t[interop.Id, OtherPlayer],
    .jetpack_enabled :: Bool,
    .jetpack_sfx :: geng.audio.Effect,
    .flate_sfx :: Option.t[type { geng.audio.Effect, .dir :: Int32 }],
};

const reset_player = (.skin) -> Entity => {
    .position = { 0, 0, 10 },
    .velocity = { 0, 0, 0 },
    .rotation = Quat.IDENTITY,
    .angular_velocity = { 0, 0, 0 },
    .skin,
    .can_jump = false,
    .scale = 1,
};

const restart = (self :: &mut Game) => (
    self^.player = reset_player();
);

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
            @native "glEnable(GL_BLEND)";
            @native "glBlendFunc(GL_SRC_ALPHA, GL_ONE_MINUS_SRC_ALPHA)";
            let assets = Assets.load();
            let water = (
                let mut v :: Vec2 = Vec2.mul({ 1, -1 }, 1000);
                let mut vs = ArrayList.new();
                for (_ :: Int32) in 0..4 do (
                    &mut vs |> ArrayList.push_back(v);
                    v = { -v.1, v.0 };
                );
                let vertex = i => {
                    .a_pos = { ...vs.[i], 0 },
                    .a_uv = Vec2.mul(vs.[i], 0.3),
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
                    .texture = assets.textures.water,
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
                .water,
                .model_renderer = Model.Renderer.init(),
                .player = reset_player(.skin = 0),
                .other_players = OrdMap.new(),
                .jetpack_enabled = false,
                .flate_sfx = :None,
                .jetpack_sfx = geng.audio.play_with(assets.sfx.jetpack, { .volume = 0, .@"loop" = true }),
            }
        ),
        .draw = self => with_return (
            with Assets.Ctx = self^.assets;
            with Model.Renderer.Ctx = self^.model_renderer;
            with Model.PlayerCtx = {
                .position = self^.player.position,
                .radius = self^.player.scale,
            };
            with geng.CameraUniforms.Ctx = geng.CameraUniforms.init(
                self^.camera,
                .framebuffer_size = geng.get_window_size(),
            );
            ugli.clear({ 0.8, 0.8, 1, 1 });
            for level_model in &self^.assets.models.level |> ArrayList.iter do (
                Model.draw(level_model^.model, Mat4.IDENTITY);
            );
            (
                with Model.PlayerCtx = {
                    .position = self^.player.position,
                    .radius = 0,
                };
                Entity.draw(&self^.player, .jetpack = self^.jetpack_enabled);
            );
            for &{ .key = _, .value = ref other_player } in &self^.other_players |> OrdMap.iter do (
                OtherPlayer.draw(other_player);
            );
            Model.draw(self^.water, Mat4.IDENTITY);
        ),
        .update = (self, delta_time) => with_return (
            let delta_time = min(delta_time, 0.050);
            # handle_mmo(self);
            geng.audio.Effect.set_volume(self^.jetpack_sfx, if self^.jetpack_enabled then 1 else 0);
            let mut max_speed = MAX_SPEED;
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
                if self^.player.position.2 < 0 then (
                    let water_force = 5;
                    let target_velocity :: Vec3 = {
                        ...Vec2.rotate(
                            Vec2.mul(Vec2.normalize_or_zero(wasd), player_speed),
                            self^.camera.rotation,
                        ),
                        player_speed,
                    };
                    self^.player.velocity = Vec3.add(
                        self^.player.velocity,
                        Vec3.mul(
                            Vec3.sub(target_velocity, self^.player.velocity),
                            min(water_force * delta_time, 1),
                        ),
                    );
                ) else (
                    let gravity = 50;
                    self^.player.velocity.2 -= gravity * delta_time;
                );
            );

            let scale_dir = if not self^.jetpack_enabled and geng.input.Key.is_pressed(:Space) then (
                if self^.player.scale < MAX_SCALE then (
                    1
                ) else 0
            ) else (
                if self^.player.scale > MIN_SCALE then (
                    -1
                ) else 0
            );
            if scale_dir != 0 then (
                let play = if self^.flate_sfx is :Some { sfx, .dir = cur_dir } then (
                    if cur_dir != scale_dir then (
                        geng.audio.Effect.stop(sfx);
                        true
                    ) else (
                        false
                    )
                ) else true;
                if play then (
                    let volume = if scale_dir > 0 then 1 else (
                        (self^.player.scale - MIN_SCALE) / (MAX_SCALE - MIN_SCALE)
                    );
                    let sfx = geng.audio.play_with(
                        if scale_dir > 0 then self^.assets.sfx.inflation else self^.assets.sfx.deflation,
                        { .volume = volume * 0.3, .@"loop" = false },
                    );
                    self^.flate_sfx = :Some { sfx, .dir = scale_dir };
                );
            );
            let scale_speed = Int32_to_Float32(scale_dir);
            let scale_time = 0.2;
            let scale_speed = scale_speed / scale_time;
            self^.player.scale = clamp(
                self^.player.scale + scale_speed * delta_time,
                .min = MIN_SCALE,
                .max = MAX_SCALE,
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
            for { type_index, level_model } in (
                &self^.assets.models.level
                    |> ArrayList.iter
                    |> std.iter.enumerate
            ) do (
                if collisions.collide_and_react(
                    .position = &mut self^.player.position,
                    .velocity = &mut self^.player.velocity,
                    .angular_velocity = &mut self^.player.angular_velocity,
                    .radius_change_speed = scale_speed,
                    .radius = self^.player.scale,
                    .mesh = &level_model^.collision_mesh,
                ) is :Some collision then (
                    if type_index == 1 then (
                        restart(self);
                    );
                    let volume = abs(collision.velocity_along_normal) / MAX_SPEED;
                    if volume > 0.1 then (
                        geng.audio.play_with(
                            level_model^.sfx,
                            { .volume, .@"loop" = false },
                        );
                    );
                );
            );
            self^.player.velocity = Vec3.clamp_len(self^.player.velocity, max_speed);
            self^.camera.position = Vec3.add(self^.player.position, { 0, 0, 3 });
        ),
        .handle_event = (self, event) => (
            match event with (
                | :KeyPress :R => (
                    restart(self);
                )
                | :KeyPress :F => (
                    self^.jetpack_enabled = not self^.jetpack_enabled;
                )
                | :KeyPress :Enter => (
                    self^.player.skin = (self^.player.skin + 1) % ArrayList.length(&self^.assets.models.skins);
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
