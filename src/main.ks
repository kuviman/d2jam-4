use (import "lib/_lib.ks").*;
use (import "./assets.ks").*;
use (import "./model.ks").*;

const badcop = import "../net/bindings.ks";

const collisions = import "./collisions.ks";

const FINISH :: Vec3 = { -120.198761, -1.251943, 147.323959 };

module:

const Entity = newtype {
    .skin :: Int32,
    .position :: Vec3,
    .velocity :: Vec3,
    .flat_rot :: Angle,
    .rotation :: Quat,
    .angular_velocity :: Vec3,
    .can_jump :: Bool,
    .scale :: Float32,
};

const player_speed = 15;
const player_acceleration = 20;

const MIN_SCALE = 1;
const MAX_SCALE = 2;

const MAX_SPEED = 200;

impl Entity as module = (
    module:

    const draw = (self :: &Entity, .jetpack :: Bool) => (
        draw_skin(
            self^.skin,
            self^.position,
            self^.velocity,
            self^.scale,
            self^.flat_rot,
            self^.rotation,
            .jetpack,
        );
    );
);

const draw_skin = (
    skin :: Int32,
    position :: Vec3,
    velocity :: Vec3,
    scale :: Float32,
    flat_rot :: Angle,
    rotation :: Quat,
    .jetpack :: Bool,
) => (
    let assets = @current Assets.Ctx;
    if jetpack then (
        let angle = Angle.from_degrees(1000 * geng.time_since_start());
        Model.draw(
            if skin == 5 then assets.models.badarms else assets.models.jetpack,
            false,
            Mat4.translate(position)
                |> Mat4.mul_mat(Mat4.rotate(Vec3.cross({ 0, 0, 1 }, velocity), Angle.from_degrees(30 / player_speed)))
                |> Mat4.mul_mat(Mat4.rotate_z(angle)),
        );
    );
    if skin == 16 then (
        Model.draw(
            assets.models.wormy,
            false,
            Mat4.translate(Vec3.add(position, { 0, 0, -scale + MIN_SCALE }))
                |> Mat4.mul_mat(Mat4.rotate_z(flat_rot)),
        );
    );
    if not jetpack or skin != 5 then (
        Model.draw(
            assets.models.skins.[skin],
            false,
            Mat4.translate(position)
                |> Mat4.mul_mat(Mat4.scale_uniform(scale))
                |> Mat4.mul_mat(Quat.into_mat4(rotation)),
        );
    );
);

include "./other_player.ks";

const TimerState = newtype (
    | :WaitForMove
    | :Working Float32
    | :Win Float32
    | :Disabled
);

const Game = newtype {
    .camera :: geng.Camera,
    .assets :: Assets.t,
    .model_renderer :: Model.Renderer,
    .water :: Model.t,
    .player :: Entity,
    .other_players :: OrdMap.t[badcop.Id, OtherPlayer],
    .jetpack_enabled :: Bool,
    .cheated :: Bool,
    .jetpack_sfx :: geng.audio.Effect,
    .flate_sfx :: Option.t[type { geng.audio.Effect, .dir :: Int32 }],
    .timer :: TimerState,
    .next_physics :: Float32,
    .dragon_scales :: ArrayList.t[DragonScale],
    .next_send :: Float32,
    .dead :: Bool,
    .dead_timer :: Float32,
    .connected :: Bool,
};

const DragonScale = newtype {
    .position :: Vec3,
    .collected :: Bool,
};

const respawn_dragon_scales = () => (
    let mut dragon_scales = ArrayList.new();
    let add = position => (
        let scale = {
            .position,
            .collected = false,
        };
        &mut dragon_scales |> ArrayList.push_back(scale);
    );
    add({ -166.625580, -0.227342, 21.092628 });
    add({ 46.816666, -0.005385, 0.049985 });
    add({ -138.585251, -59.781757, 47.580807 });
    add({ -80.768204, 0.142232, 101.941040 });
    add({ -71.015900, 28.825523, 25.515934 });
    add({ -25.596405, -4.421812, 117.133064 });
    dragon_scales
);

const reset_player = (.skin) -> Entity => {
    .position = { 0, 0, 10 },
    .velocity = { 0, 0, 0 },
    .rotation = Quat.IDENTITY,
    .flat_rot = Angle.from_degrees(0),
    .angular_velocity = { 0, 0, 0 },
    .skin,
    .can_jump = false,
    .scale = 1,
};

const restart = (self :: &mut Game) => (
    self^.dead = false;
    self^.dead_timer = 0;
    self^.player = reset_player(.skin = self^.player.skin);
    self^.timer = :WaitForMove;
    self^.cheated = false;
    self^.jetpack_enabled = false;
    self^.dragon_scales = respawn_dragon_scales();
);

const is_jump_pressed = () => (
    geng.input.Key.is_pressed(:Space) or geng.input.Key.is_pressed(:Backspace)
);

const update_step = (self :: &mut Game, delta_time :: Float32) => with_return (
    if self^.dead then return;
    let old_z = self^.player.position.2;
    self^.player.position = Vec3.add(
        self^.player.position,
        Vec3.mul(self^.player.velocity, delta_time),
    );
    let new_z = self^.player.position.2;
    if old_z >= 0 and new_z < 0 or old_z < 0 and new_z >= 0 then (
        let volume = min(abs(self^.player.velocity.2) / player_speed * 2 - 1, 1);
        if volume > 0.1 then (
            geng.audio.play_with(
                self^.assets.sfx.splash,
                { .volume, .@"loop" = false },
            );
        );
    );
    let mut max_speed = MAX_SPEED;
    let scale_dir = if not self^.jetpack_enabled and is_jump_pressed() then (
        if self^.player.scale < MAX_SCALE then (
            1
        ) else 0
    ) else (
        if self^.player.scale > MIN_SCALE then (
            -1
        ) else 0
    );
    let scale_speed = Int32_to_Float32(scale_dir);
    let scale_time = 0.2;
    let scale_speed = scale_speed / scale_time;
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
            .properties = &level_model^.properties,
        ) is :Some collision then (
            if type_index == 1 then (
                self^.dead = true;
            );
            let volume = min(abs(collision.velocity_along_normal) / 50, 1);
            if volume > 0.1 then (
                geng.audio.play_with(
                    level_model^.sfx,
                    { .volume, .@"loop" = false },
                );
            );
        );
    );
    self^.player.velocity = Vec3.clamp_len(self^.player.velocity, max_speed);
);

const send_update = (self :: &mut Game) => (
    badcop.send_update({
        .position = self^.player.position,
        .velocity = self^.player.velocity,
        .rotation = self^.player.rotation,
        .angular_velocity = self^.player.angular_velocity,
        .skin = self^.player.skin,
        .jetpack = self^.jetpack_enabled,
        .scale = self^.player.scale,
    });
);

const handle_mmo = (self :: &mut Game) => (
    let new_connection_state = badcop.is_connected();
    if new_connection_state != self^.connected then (
        self^.connected = new_connection_state;
        if new_connection_state then (
                self^.other_players = OrdMap.new();
        );
    );
    while badcop.poll_message() is :Some msg do (
        match msg with (
            | :Connected id => (
                print("Player connected: " + to_string(id));
                &mut self^.other_players |> OrdMap.add(id, OtherPlayer.new());
            )
            | :Disconnected id => (
                print("Player disconnected: " + to_string(id));
                &mut self^.other_players |> OrdMap.remove(id);
            )
            | :UpdatePlayer { .id, .data } => (
                let player = &mut self^.other_players
                    |> OrdMap.get_mut(id)
                    |> Option.unwrap;
                OtherPlayer.update_net(player, data);
            )
            | :PlayerMeta _ => (
            )
        )
    );

    @comment_out (
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
);

@eval (
    impl Game as geng.App = {
        .init = () => (
            SDL.SetWindowRelativeMouseMode((@current geng.Context).window, true);
            @native "glEnable(GL_BLEND)";
            @native "glBlendFunc(GL_SRC_ALPHA, GL_ONE_MINUS_SRC_ALPHA)";
            @native "glCullFace(GL_BACK)";
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
                .dragon_scales = respawn_dragon_scales(),
                .next_send = 0,
                .dead = false,
                .dead_timer = 0,
                .assets,
                .water,
                .model_renderer = Model.Renderer.init(),
                .player = reset_player(.skin = 0),
                .other_players = OrdMap.new(),
                .jetpack_enabled = false,
                .cheated = false,
                .flate_sfx = :None,
                .jetpack_sfx = geng.audio.play_with(assets.sfx.jetpack, { .volume = 0, .@"loop" = true }),
                .timer = :WaitForMove,
                .next_physics = 0,
                .connected = false,
            }
        ),
        .draw = self => with_return (
            self^.camera.position = Vec3.add(self^.player.position, { 0, 0, 3 });
            with Assets.Ctx = self^.assets;
            with Model.Renderer.Ctx = self^.model_renderer;
            with Model.PlayerCtx = {
                .position = self^.player.position,
                .radius = if self^.dead then 0 else self^.player.scale,
            };
            with geng.CameraUniforms.Ctx = geng.CameraUniforms.init(
                self^.camera,
                .framebuffer_size = geng.get_window_size(),
            );
            ugli.clear({ 0.8, 0.8, 1, 1 });
            for level_model in &self^.assets.models.level |> ArrayList.iter do (
                Model.draw(level_model^.model, level_model^.properties.animated, Mat4.IDENTITY);
            );
            @native "glEnable(GL_CULL_FACE)";
            for &model in &self^.assets.models.level_nocollisions |> ArrayList.iter do (
                Model.draw(model, false, Mat4.IDENTITY);
            );
            # @native "glDisable(GL_CULL_FACE)";
            let mut collected_scales :: Int32 = 0;
            for scale in &self^.dragon_scales |> ArrayList.iter do (
                if scale^.collected then (
                    collected_scales += 1;
                    continue;
                );
                let matrix = Mat4.translate(scale^.position)
                    |> Mat4.mul_mat(Mat4.rotate_z(Angle.from_degrees(geng.time_since_start() * 90)));
                Model.draw(self^.assets.models.dragon_scale, false, matrix);
            );
            if not self^.dead then (
                with Model.PlayerCtx = {
                    .position = self^.player.position,
                    .radius = 0,
                };
                Entity.draw(&self^.player, .jetpack = self^.jetpack_enabled);
            );
            for &{ .key = _, .value = ref other_player } in &self^.other_players |> OrdMap.iter do (
                OtherPlayer.draw(other_player);
            );
            Model.draw(self^.water, true, Mat4.IDENTITY);

            let height = 12;
            let distance = 8;
            font.Font.draw(
                &self^.assets.font,
                "WASD to ROLL",
                .matrix = Mat4.rotate_z(Angle.from_degrees(-90))
                    |> Mat4.mul_mat(Mat4.translate({ 0, distance, height + 0.5}))
                    |> Mat4.mul_mat(Mat4.rotate_x(Angle.from_degrees(90))),
                .color = { 0, 0, 0, 1 },
                .align = 0.5,
            );
            font.Font.draw(
                &self^.assets.font,
                "Mouse to LOOK",
                .matrix = Mat4.rotate_z(Angle.from_degrees(-90))
                    |> Mat4.mul_mat(Mat4.translate({ 0, distance, height - 0.5}))
                    |> Mat4.mul_mat(Mat4.rotate_x(Angle.from_degrees(90))),
                .color = { 0, 0, 0, 1 },
                .align = 0.5,
            );
            font.Font.draw(
                &self^.assets.font,
                "R to RESTART",
                .matrix = Mat4.rotate_z(Angle.from_degrees(10))
                    |> Mat4.mul_mat(Mat4.translate({ 0, distance, height + 0.5}))
                    |> Mat4.mul_mat(Mat4.rotate_x(Angle.from_degrees(90))),
                .color = { 0, 0, 0, 1 },
                .align = 0.5,
            );
            font.Font.draw(
                &self^.assets.font,
                "F to CHEAT",
                .matrix = Mat4.rotate_z(Angle.from_degrees(10))
                    |> Mat4.mul_mat(Mat4.translate({ 0, distance, height - 0.5}))
                    |> Mat4.mul_mat(Mat4.rotate_x(Angle.from_degrees(90))),
                .color = { 0, 0, 0, 1 },
                .align = 0.5,
            );
            font.Font.draw(
                &self^.assets.font,
                "Enter to CHANGE SKIN",
                .matrix = Mat4.rotate_z(Angle.from_degrees(90))
                    |> Mat4.mul_mat(Mat4.translate({ 0, distance, height}))
                    |> Mat4.mul_mat(Mat4.rotate_x(Angle.from_degrees(90))),
                .color = { 0, 0, 0, 1 },
                .align = 0.5,
            );
            font.Font.draw(
                &self^.assets.font,
                "Space to SCALE",
                .matrix = Mat4.rotate_z(Angle.from_degrees(-170))
                    |> Mat4.mul_mat(Mat4.translate({ 0, distance, height}))
                    |> Mat4.mul_mat(Mat4.rotate_x(Angle.from_degrees(90))),
                .color = { 0, 0, 0, 1 },
                .align = 0.5,
            );

            with geng.CameraUniforms.Ctx = geng.CameraUniforms.init(
                {
                    .position = { 0, 0, 0 },
                    .rotation = Angle.from_degrees(90),
                    .attack = Angle.from_degrees(90),
                    .fov = Angle.from_degrees(90),
                    .distance = 10,
                },
                .framebuffer_size = geng.get_window_size(),
            );
            let time :: Option.t[Float32] = match self^.timer with (
                | :Working t => :Some t
                | :Win t => :Some t
                | _ => :None
            );
            let color = if self^.cheated then { 1, 0, 0, 1 } else { 0, 0, 0, 1 };
            if self^.timer is :Win _ then (
                font.Font.draw(
                    &self^.assets.font,
                    "YOU HAVE SCALED THE MOUNTAIN",
                    .matrix = Mat4.translate({ 0, 5, 0})
                        |> Mat4.mul_mat(Mat4.rotate_x(Angle.from_degrees(10))),
                    .color,
                    .align = 0.5,
                );
                font.Font.draw(
                    &self^.assets.font,
                    to_string(collected_scales) + " dragon scales collected",
                    .matrix = Mat4.translate({ 0, 3, 0}),
                    .color,
                    .align = 0.5,
                );
                if self^.cheated then (
                    font.Font.draw(
                        &self^.assets.font,
                        "with cheats",
                        .matrix = Mat4.translate({ 0, 4, 0}),
                        .color,
                        .align = 0.5,
                    );
                );
            );
            if not self^.connected then (
                font.Font.draw(
                    &self^.assets.font,
                    "disconnected",
                    .matrix = Mat4.translate({ 0, 9.2, 0}),
                    .color = {1, 0, 0, 1},
                    .align = 0.5,
                );
            );
            if time is :Some t then (
                font.Font.draw(
                    &self^.assets.font,
                    (
                        let seconds :: Int32 = @native "\(t)";
                        let minutes = seconds / 60;
                        let seconds = seconds % 60;
                        to_string(minutes)
                        + ":"
                        + to_string(seconds / 10)
                        + to_string(seconds % 10)
                    ),
                    .matrix = Mat4.translate({ 0, 7, 0})
                        |> Mat4.mul_mat(Mat4.rotate_x(Angle.from_degrees(20)))
                        |> Mat4.mul_mat(Mat4.scale_uniform(2)),
                    .color,
                    .align = 0.5,
                );
            );
        ),
        .update = (self, delta_time) => with_return (
            let delta_time = min(delta_time, 0.050);
            if self^.dead then (
                self^.dead_timer += delta_time;
                if self^.dead_timer > 1 then (
                    restart(self);
                );
            );
            const MUSIC_FADE_TIME = 5;
            geng.audio.Effect.set_volume(
                self^.assets.music,
                (
                    let target_volume = if self^.player.position.2 < 67 then 1 else 0;
                    let current_volume = geng.audio.Effect.get_volume(self^.assets.music)
                        / MUSIC_VOLUME;
                    let max_delta = min(1, delta_time / MUSIC_FADE_TIME);
                    current_volume + clamp(
                        target_volume - current_volume,
                        .min = -max_delta,
                        .max = max_delta,
                    )
                )
                    * MUSIC_VOLUME,
            );
            geng.audio.Effect.set_volume(
                self^.assets.music_high,
                (
                    let target_volume = if self^.player.position.2 > 74 then 1 else 0;
                    let current_volume = geng.audio.Effect.get_volume(self^.assets.music_high)
                        / MUSIC_VOLUME;
                    let max_delta = min(1, delta_time / MUSIC_FADE_TIME);
                    current_volume + clamp(
                        target_volume - current_volume,
                        .min = -max_delta,
                        .max = max_delta,
                    )
                )
                    * MUSIC_VOLUME,
            );
            for &mut { .key = _, .value = ref mut o } in &mut self^.other_players |> OrdMap.iter_mut do (
                OtherPlayer.update(o, delta_time);
            );
            if self^.timer is :Win _ then () else (
                for scale in &mut self^.dragon_scales |> ArrayList.iter_mut do (
                    if scale^.collected then continue;
                    if Vec3.length(Vec3.sub(self^.player.position, scale^.position)) < self^.player.scale + 1 then (
                        geng.audio.play(self^.assets.sfx.collect);
                        scale^.collected = true;
                    );
                );
            );
            self^.next_send -= delta_time;
            if self^.next_send < 0 then (
                self^.next_send = 1 / 10;
                send_update(self);
            );
            if self^.timer is :Working ref mut time then (
                time^ += delta_time;
            );
            handle_mmo(self);
            geng.audio.Effect.set_volume(self^.jetpack_sfx, if self^.jetpack_enabled then 0.5 else 0);
            if Vec3.length(Vec3.sub(self^.player.position, FINISH)) < self^.player.scale then (
                if self^.timer is :Working t then (
                    geng.audio.play(self^.assets.sfx.win);
                    badcop.beat_game(Float32_to_Int32(t));
                    self^.timer = :Win t;
                );
            );
            if self^.jetpack_enabled then (
                match self^.timer with (
                    | :Win _ => ()
                    | _ => (
                        self^.cheated = true;
                    )
                )
            );
            if false and self^.jetpack_enabled then (
                let disable = match self^.timer with (
                    | :WaitForMove => true
                    | :Working _ => true
                    | _ => false
                );
                if disable then (
                    self^.timer = :Disabled;
                );
            );
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
            if Vec2.length(wasd) > 0.1 then (
                if self^.timer is :WaitForMove then (
                    self^.timer = :Working 0;
                );
                self^.player.flat_rot = Angle.add(Vec2.arg(wasd), self^.camera.rotation);
            );
            if self^.jetpack_enabled then (
                let target_velocity :: Vec3 = {
                    ...Vec2.rotate(
                        Vec2.mul(Vec2.normalize_or_zero(wasd), player_speed),
                        self^.camera.rotation,
                    ),
                    (
                        let mut z = 0;
                        if is_jump_pressed() then (
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
                    let target_velocity :: Vec3 = {
                        ...Vec2.rotate(
                            Vec2.mul(Vec2.normalize_or_zero(wasd), player_speed),
                            self^.camera.rotation,
                        ),
                        self^.player.velocity.2,
                    };
                    let air_control = 0.5;
                    self^.player.velocity = Vec3.add(
                        self^.player.velocity,
                        Vec3.mul(
                            Vec3.sub(target_velocity, self^.player.velocity),
                            min(air_control * delta_time, 1),
                        ),
                    );
                    let gravity = 50;
                    self^.player.velocity.2 -= gravity * delta_time;
                );
            );

            let scale_dir = if not self^.jetpack_enabled and is_jump_pressed() then (
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
            self^.next_physics -= delta_time;
            while self^.next_physics < -0.0001 do (
                const MAX_DISTANCE_A_FRAME = 0.2;
                let max_delta_time = MAX_DISTANCE_A_FRAME / max(Vec3.length(self^.player.velocity), 0.1);
                let step = min(max_delta_time, -self^.next_physics);
                update_step(self, step);
                self^.next_physics += step;
            );
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
                | :KeyPress :K => (
                    print(to_string(self^.player.position));
                )
                | :MousePress _ => (
                    SDL.SetWindowRelativeMouseMode((@current geng.Context).window, true);
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
    badcop.init(address);
    badcop.set_name("<todo name>");
    # let c = client.connect(address);
    # with client.Ctx = c;
    geng.run[Game]();
);
