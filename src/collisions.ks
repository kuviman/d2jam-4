use (import "./lib/la/_lib.ks").*;

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
    ()
);

const collide_face = (entity :: Entity, face :: &Face) -> Option.t[Collision] => (
    let mut result :: Collision = {
        .penetration = -1,
        .normal = { 0, 0, 0 },
    };
    let update = (collision :: Collision) => (
        if collision.penetration > result.penetration then (
            result = collision;
        );
    );
    for &p in &face^.vs |> ArrayList.iter do (
        let dv = Vec3.sub(entity.position, p);
        let len = Vec3.length(dv);
        if len < entity.radius then (
            update({ .penetration = entity.radius - len, .normal = Vec3.normalize(dv) });
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
            update({ .penetration = entity.radius - length, .normal = Vec3.normalize(delta) });
        );
    );
    if result.penetration <= 0 then (
        :None
    ) else (
        :Some result
    )
);

const collide = (entity :: Entity, mesh :: &Mesh) -> Option.t[Collision] => with_return (
    if entity.position.2 < entity.radius then (
        return :Some {
            .penetration = entity.radius - entity.position.2,
            .normal = { 0, 0, 1 },
        };
    );
    for face in &mesh^.faces |> ArrayList.iter do (
        if collide_face(entity, face) is :Some collision then (
            return :Some collision;
        );
    );
    :None
);

const collide_and_react = (
    .position :: &mut Vec3,
    .velocity :: &mut Vec3,
    .radius :: Float32,
    .mesh :: &Mesh,
) -> Bool => (
    let bounciness = 0.5;
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
        true
    ) else (
        false
    )
);
