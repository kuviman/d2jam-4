const Quat = newtype {
    .i :: Float32,
    .j :: Float32,
    .k :: Float32,
    .w :: Float32,
};

impl Quat as module = (
    module:

    const IDENTITY :: Quat = { .i = 0, .j = 0, .k = 0, .w = 1 };

    const from_axis_angle = (axis :: Vec3, angle :: Angle) -> Quat => (
        let angle = Angle.div(angle, 2);
        let { sin, cos } = Angle.sin_cos(angle);
        let v = Vec3.mul(axis, sin);
        { .i = v.0, .j = v.1, .k = v.2, .w = cos }
    );

    const length = (q :: Quat) -> Float32 => (
        math.sqrt(length2(q))
    );

    const length2 = (q :: Quat) -> Float32 => (
        q.i * q.i + q.j * q.j + q.k * q.k + q.w * q.w
    );

    const normalize = (q :: Quat) -> Quat => (
        div(q, length(q))
    );

    const mul_quat = (a :: Quat, b :: Quat) -> Quat => {
        .i = a.w * b.i + a.i * b.w + a.j * b.k - a.k * b.j,
        .j = a.w * b.j - a.i * b.k + a.j * b.w + a.k * b.i,
        .k = a.w * b.k + a.i * b.j - a.j * b.i + a.k * b.w,
        .w = a.w * b.w - a.i * b.i - a.j * b.j - a.k * b.k,
    };

    const mul = (q :: Quat, k :: Float32) -> Quat => {
        .i = q.i * k,
        .j = q.j * k,
        .k = q.k * k,
        .w = q.w * k,
    };

    const div = (q :: Quat, k :: Float32) -> Quat => {
        .i = q.i / k,
        .j = q.j / k,
        .k = q.k / k,
        .w = q.w / k,
    };

    const add = (a :: Quat, b :: Quat) -> Quat => {
        .i = a.i + b.i,
        .j = a.j + b.j,
        .k = a.k + b.k,
        .w = a.w + b.w,
    };

    const sub = (a :: Quat, b :: Quat) -> Quat => {
        .i = a.i - b.i,
        .j = a.j - b.j,
        .k = a.k - b.k,
        .w = a.w - b.w,
    };

    const into_mat4 = ({ .i, .j, .k, .w } :: Quat) -> Mat4 => (
        let ww = w * w;
        let ii = i * i;
        let jj = j * j;
        let kk = k * k;
        let ij = i * j * 2;
        let wk = w * k * 2;
        let wj = w * j * 2;
        let ik = i * k * 2;
        let jk = j * k * 2;
        let wi = w * i * 2;
        {
            { ww + ii - jj - kk, ij - wk, wj + ik, 0 },
            { wk + ij, ww - ii + jj - kk, jk - wi, 0 },
            { ik - wj, wi + jk, ww - ii - jj + kk, 0 },
            { 0, 0, 0, 1 },
        }
    );
);
