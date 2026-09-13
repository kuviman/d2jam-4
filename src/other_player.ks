use (import "./interpolate.ks").*;

const Interpolated = [T] newtype {
    .value :: T,
    .target_value :: T,
    .time_remaining :: Float32,
};

const init_interpolated = [T] (value :: T) -> Interpolated[T] => {
    .value,
    .target_value = value,
    .time_remaining = 0,
};

const update_interpolated = [T] (
    self :: &mut Interpolated[T],
    delta_time :: Float32,
) => (
    let delta_time = min(delta_time, self^.time_remaining);
    if self^.time_remaining > 0.0001 then (
        self^.value = (T as Interpolatable).lerp(
            self^.value,
            self^.target_value,
            delta_time / self^.time_remaining,
        );
        self^.time_remaining -= delta_time;
    );
);

const update_interpolated_net = [T] (
    self :: &mut Interpolated[T],
    new_value :: T,
    new_speed :: T,
) => (
    let predicted_value = (T as Interpolatable).add(
        new_value,
        (T as Interpolatable).mul(new_speed, PREDICTION_T),
    );
    self^.target_value = predicted_value;
    self^.time_remaining = PREDICTION_T;
);

const OtherPlayer = newtype {
    .skin :: Int32,
    .position :: Interpolated[Vec3],
    .rotation :: Interpolated[Quat],
    .scale :: Interpolated[Float32],
    .jetpack :: Bool,
};

const PREDICTION_T :: Float32 = 0.3;

impl OtherPlayer as module = (
    module:

    const new = () -> OtherPlayer => {
        .skin = 0,
        .position = init_interpolated({ 0, 0, 0 }),
        .rotation = init_interpolated(Quat.IDENTITY),
        .scale = init_interpolated(0),
        .jetpack = false,
    };

    const update_net = (self :: &mut OtherPlayer, data :: badcop.PlayerData) => (
        update_interpolated_net(&mut self^.position, data.position, data.velocity);
        update_interpolated_net(&mut self^.rotation, data.rotation, Quat.ZERO);
        update_interpolated_net(&mut self^.scale, data.scale, 0);
        self^.skin = data.skin;
        self^.jetpack = data.jetpack;
    );

    const update = (self :: &mut OtherPlayer, delta_time :: Float32) => (
        update_interpolated(&mut self^.position, delta_time);
        update_interpolated(&mut self^.rotation, delta_time);
        update_interpolated(&mut self^.scale, delta_time);
    );

    const draw = (self :: &OtherPlayer) => (
        let assets = @current Assets.Ctx;
        if not self^.jetpack or self^.skin != 5 then (
            Model.draw(
                assets.models.skins.[self^.skin],
                false,
                Mat4.translate(self^.position.value)
                    |> Mat4.mul_mat(Mat4.scale_uniform(self^.scale.value))
                    |> Mat4.mul_mat(Quat.into_mat4(self^.rotation.value)),
            );
        );
        if self^.jetpack then (
            let mut vel = { 0, 0, 0 };
            if self^.position.time_remaining > 0.001 then (
                vel = Vec3.div(
                    Vec3.sub(self^.position.target_value, self^.position.value),
                    self^.position.time_remaining,
                );
            );
            draw_jetpack(self^.position.value, vel, self^.skin);
        );
    );
);
