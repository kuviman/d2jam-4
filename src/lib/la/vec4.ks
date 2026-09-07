const Vec4 = newtype { Float32, Float32, Float32, Float32 };

impl Vec4 as module = (
    module:

    const dot = (a :: Vec4, b :: Vec4) -> Float32 => (
        a.0 * b.0 + a.1 * b.1 + a.2 * b.2 + a.3 * b.3
    );
);
