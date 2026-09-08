module:

const tan = (x :: Float32) -> Float32 => (
    @native "#include <math.h>";
    @native "tanf(\(x))"
);

const sin = (x :: Float32) -> Float32 => (
    @native "#include <math.h>";
    @native "sinf(\(x))"
);

const cos = (x :: Float32) -> Float32 => (
    @native "#include <math.h>";
    @native "cosf(\(x))"
);

const sqrt = (x :: Float32) -> Float32 => (
    @native "#include <math.h>";
    @native "sqrtf(\(x))"
);

const atan2 = (y :: Float32, x :: Float32) -> Float32 => (
    @native "#include <math.h>";
    @native "atan2f(\(y), \(x))"
);
