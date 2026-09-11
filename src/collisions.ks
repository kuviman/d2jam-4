use (import "./lib/la/_lib.ks").*;
use (import "./lib/common.ks").*;

module:

const Collision = newtype {
    .penetration :: Float32,
    .normal :: Vec3,
};

const Entity = newtype {
    .position :: Vec3,
    .radius :: Float32,
};

const Face = newtype {
    .vs :: ArrayList.t[Vec3],
    .normal :: Vec3,
};

const Mesh = newtype {
    .faces :: ArrayList.t[Face],
};

impl Mesh as module = (
    module:

    const new = (faces :: ArrayList.t[Face]) -> Mesh => (
        { .faces }
    );
);

const update = (result :: &mut Collision, collision :: Collision) => (
    if collision.penetration > result^.penetration then (
        result^ = collision;
    );
);

const collide_face = (result :: &mut Collision, entity :: Entity, face :: &Face) => (
    for &p in &face^.vs |> ArrayList.iter do (
        let dv = Vec3.sub(entity.position, p);
        let len = Vec3.length(dv);
        if len < entity.radius then (
            update(result, { .penetration = entity.radius - len, .normal = Vec3.normalize(dv) });
        );
    );
    for i in 0..3 do (
        let a = face^.vs.[i];
        let b = face^.vs.[(i + 1) % 3];
        if Vec3.dot(Vec3.sub(b, a), Vec3.sub(entity.position, a)) <= 0 then (
            continue;
        );
        if Vec3.dot(Vec3.sub(a, b), Vec3.sub(entity.position, b)) <= 0 then (
            continue;
        );
        let v = Vec3.normalize(Vec3.sub(b, a));
        let t = Vec3.dot(Vec3.sub(entity.position, a), v);
        let closest_point = Vec3.add(a, Vec3.mul(v, t));
        let delta = Vec3.sub(entity.position, closest_point);
        let length = Vec3.length(delta);
        if length < entity.radius then (
            update(result, { .penetration = entity.radius - length, .normal = Vec3.normalize(delta) });
        );
    );
    let d = Vec3.dot(Vec3.sub(entity.position, face^.vs.[0]), face^.normal);
    if 0 < d and d < entity.radius then (
        let closest_point = Vec3.sub(entity.position, Vec3.mul(face^.normal, d));
        with_return (
            for i in 0..3 do (
                let a = face^.vs.[i];
                let b = face^.vs.[(i + 1) % 3];
                if Vec3.dot(Vec3.cross(face^.normal, Vec3.sub(b, a)), Vec3.sub(closest_point, a)) < 0 then (
                    return;
                );
            );
            update(result, { .penetration = entity.radius - d, .normal = face^.normal });
        );
    );
);

const collide = (entity :: Entity, mesh :: &Mesh) -> Option.t[Collision] => with_return (
    let mut result :: Collision = {
        .penetration = -1,
        .normal = { 0, 0, 0 },
    };
    for face in &mesh^.faces |> ArrayList.iter do (
        collide_face(&mut result, entity, face);
    );
    if result.penetration <= 0 then (
        :None
    ) else (
        :Some result
    )
);

const collide_and_react = (
    .position :: &mut Vec3,
    .velocity :: &mut Vec3,
    .angular_velocity :: &mut Vec3,
    .radius :: Float32,
    .mesh :: &Mesh,
) -> Bool => (
    let bounciness = 0.1;
    if collide({ .position = position^, .radius }, mesh) is :Some collision then (
        position^ = Vec3.add(
            position^,
            Vec3.mul(collision.normal, collision.penetration),
        );
        let velocity_along_normal = Vec3.dot(velocity^, collision.normal);
        if velocity_along_normal < 0 then (
            velocity^ = Vec3.add(
                velocity^,
                Vec3.mul(collision.normal, -(1 + bounciness) * velocity_along_normal),
            );
        );
        let relative_angular_velocity = Vec3.add(
            angular_velocity^,
            Vec3.cross(velocity^, collision.normal),
        );
        let friction = 0.5;
        let angular_impulse = Vec3.mul(
            relative_angular_velocity,
            -min(1, max(0, -velocity_along_normal) * friction),
        );
        velocity^ = Vec3.sub(
            velocity^,
            Vec3.cross(angular_impulse, collision.normal),
        );
        angular_velocity^ = Vec3.add(angular_velocity^, angular_impulse);
        true
    ) else (
        false
    )
);
