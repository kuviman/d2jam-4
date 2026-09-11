default:
    echo "Hi"

build-c source="src/main.ks":
    kastc compile \
        --target c \
        --output target/compiled/main.c \
        {{source}}

build-native:
    ${CC:-gcc} \
        -pthread \
        -lm -lgc -lSDL3 -lSDL3_image -lSDL3_mixer -lGL -lGLEW -lbacktrace \
        -Wfatal-errors \
        -g -O0 \
        -o target/compiled/main.exe \
        target/compiled/main.c \
        -fsanitize=address,leak,undefined \
    # -fno-omit-frame-pointer \

build-windows-do source:
    $CC \
        -lkernel32 -luser32 -lgdi32 -lwinmm -limm32 -lole32 -loleaut32 -lversion -luuid -ladvapi32 -lsetupapi -lshell32 -lhid -lmincore \
        -mwindows \
        -lm -lgc -lSDL3 -lSDL3_image -lbacktrace \
        -Wfatal-errors \
        -g -O0 \
        -o target/compiled/main.exe \
        {{source}}

build-windows source="target/compiled/main.c":
    nix develop .#win --command just build-windows-do {{source}}

build-emscripten source="target/compiled/main.c":
    rm -rf target/web
    mkdir -p target/web
    emcc {{source}} \
        --shell-file shell.html \
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
        -s ALLOW_MEMORY_GROWTH \
        -s ASSERTIONS \
        -s ASYNCIFY \
        -w
    # -s BINARYEN_EXTRA_PASSES='--spill-pointers' \
    # -sMAX_WEBGL_VERSION=2 \

build src="src/main.ks":
    just build-c {{src}}
    just build-native

run:
    LSAN_OPTIONS='suppresions=suppr.txt' \
        ./target/compiled/main.exe --server 127.0.0.1:1234 --connect 127.0.0.1:1234

server:
    LSAN_OPTIONS='suppresions=suppr.txt' \
        ./target/compiled/main.exe --server 127.0.0.1:1234

client:
    LSAN_OPTIONS='suppresions=suppr.txt' \
        ./target/compiled/main.exe --connect 127.0.0.1:1234

serve:
    just build-c
    just build-emscripten
    caddy run

publish:
    butler push target/web kuviman/d2jam4:html5

