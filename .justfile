default:
    echo "Hi"

build-c:
    kastc compile \
        --target c \
        --output target/compiled/main.c \
        src/main.ks

build-native:
    ${CC:-gcc} \
        -lm -lgc -lSDL3 -lSDL3_image -lSDL3_mixer -lGL -lGLEW -lbacktrace \
        -Wfatal-errors \
        -fsanitize=address,leak,undefined \
        -g -O1 \
        -o target/compiled/main.exe \
        target/compiled/main.c
    # -fno-omit-frame-pointer \

build-emscripten source="target/compiled/main.c":
    rm -rf target/web
    mkdir -p target/web
    emcc {{source}} \
        -o target/web/index.html \
        -I ${BOEHMGC_WEB}/include \
        -L ${BOEHMGC_WEB}/lib \
        -lgc \
        -I ${SDL3_WEB}/include \
        -L ${SDL3_WEB}/lib \
        -l SDL3 \
        -I ${SDL3_IMAGE_WEB}/include \
        -L ${SDL3_IMAGE_WEB}/lib \
        -l SDL3_image \
        -I ${SDL3_MIXER_WEB}/include \
        -L ${SDL3_MIXER_WEB}/lib \
        -l SDL3_mixer \
        -O0 \
        -g -gsource-map \
        --use-preload-plugins \
        --preload-file assets \
        -s TOTAL_STACK=64MB \
        -s INITIAL_MEMORY=128MB \
        -s ASSERTIONS \
        -s ASYNCIFY \
        -w
    # -s BINARYEN_EXTRA_PASSES='--spill-pointers' \
    # --shell-file shell.html \
    # -sMAX_WEBGL_VERSION=2 \

run:
    just build-c
    just build-native
    LSAN_OPTIONS='suppresions=suppr.txt' \
        ./target/compiled/main.exe

serve:
    just build-c
    just build-emscripten
    caddy run

publish:
    butler push target/web kuviman/d2jam4:html5

