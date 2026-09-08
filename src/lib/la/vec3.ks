const Vec3 = newtype { Float32, Float32, Float32 };

impl Vec3 as module = (
    module:

    const xy = ({ x, y, _ } :: Vec3) -> Vec2 => { x, y };

    const add = (a :: Vec3, b :: Vec3) -> Vec3 => (
        { a.0 + b.0, a.1 + b.1, a.2 + b.2 }
    );

    const sub = (a :: Vec3, b :: Vec3) -> Vec3 => (
        { a.0 - b.0, a.1 - b.1, a.2 - b.2 }
    );

    const dot = (a :: Vec3, b :: Vec3) -> Float32 => (
        a.0 * b.0 + a.1 * b.1 + a.2 * b.2
    );

    const neg = ({ x, y, z } :: Vec3) -> Vec3 => (
        { -x, -y, -z }
    );

    const mul = ({ x, y, z } :: Vec3, k :: Float32) -> Vec3 => (
        { x * k, y * k, z * k }
    );

    const div = ({ x, y, z } :: Vec3, k :: Float32) -> Vec3 => (
        { x / k, y / k, z / k }
    );

    const length = (v :: Vec3) -> Float32 => (
        math.sqrt(length2(v))
    );

    const length2 = (v :: Vec3) -> Float32 => (
        dot(v, v)
    );

    const normalize = (v :: Vec3) -> Vec3 => (
        div(v, length(v))
    );
);
