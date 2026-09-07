const PI :: Float32 = 3.14159265359;

const Angle = newtype { .radians :: Float32 };

impl Angle as module = (
    module:

    const neg = (angle :: Angle) -> Angle => {
        .radians = -angle.radians,
    };

    const add = (a :: Angle, b :: Angle) -> Angle => {
        .radians = a.radians + b.radians,
    };

    const sub = (a :: Angle, b :: Angle) -> Angle => {
        .radians = a.radians - b.radians,
    };

    const from_degrees = (degrees :: Float32) -> Angle => (
        { .radians = degrees * PI / 180 }
    );

    const degrees = (angle :: Angle) -> Float32 => (
        angle.radians * 180 / PI
    );

    const tan = (angle :: Angle) => (
        math.tan(angle.radians)
    );

    const sin = (angle :: Angle) => (
        math.sin(angle.radians)
    );

    const cos = (angle :: Angle) => (
        math.cos(angle.radians)
    );
);
