const Mat3 = newtype { Vec3, Vec3, Vec3 };

impl Mat3 as module = (
    module:

    const transpose = (m :: Mat3) -> Mat3 => {
        { m.0.0, m.1.0, m.2.0 },
        { m.0.1, m.1.1, m.2.1 },
        { m.0.2, m.1.2, m.2.2 },
    };

    const div = (m :: Mat3, k :: Float32) -> Mat3 => {
        { m.0.0 / k, m.0.1 / k, m.0.2 / k },
        { m.1.0 / k, m.1.1 / k, m.1.2 / k },
        { m.2.0 / k, m.2.1 / k, m.2.2 / k },
    };

    const mul_mat = (a :: Mat3, b :: Mat3) -> Mat3 => (
        let b = transpose(b);
        const dot = Vec3.dot;
        let result = {
            { dot(a.0, b.0), dot(a.0, b.1), dot(a.0, b.2) },
            { dot(a.1, b.0), dot(a.1, b.1), dot(a.1, b.2) },
            { dot(a.2, b.0), dot(a.2, b.1), dot(a.2, b.2) },
        };
        # dbg.print(.a, .b, .result);
        result
    );

    const inverse = (m :: Mat3) -> Mat3 => (
        let {
            { a00, a01, a02 },
            { a10, a11, a12 },
            { a20, a21, a22 },
        } = m;

        let b01 = a22 * a11 - a12 * a21;
        let b11 = -a22 * a10 + a12 * a20;
        let b21 = a21 * a10 - a11 * a20;

        let det = a00 * b01 + a01 * b11 + a02 * b21;

        div(
            {
                { b01, -a22 * a01 + a02 * a21, a12 * a01 - a02 * a11 },
                { b11, a22 * a00 - a02 * a20, -a12 * a00 + a02 * a10 },
                { b21, -a21 * a00 + a01 * a20, a11 * a00 - a01 * a10 },
            },
            det
        )
    );

    const mul_vec = (m :: Mat3, v :: Vec3) -> Vec3 => (
        # dbg.print("BEFORE MUL", .m, .v);
        let result = {
            Vec3.dot(m.0, v),
            Vec3.dot(m.1, v),
            Vec3.dot(m.2, v),
        };
        # dbg.print(.m, .v, .result);
        result
    );
);
