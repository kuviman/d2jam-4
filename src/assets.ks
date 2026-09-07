use (import "./lib/_lib.ks").*;
use (import "./model.ks").*;

module:

const Assets = (
    module:

    const t = newtype {
        # .music :: geng.audio.Buffer,
        .sfx :: Sfx,
        .font :: font.Font,
        .shaders :: Shaders,
        .textures :: Textures,
        .models :: Models,
    };

    const Shaders = newtype {
        .model :: ugli.Program,
    };

    const Sfx = newtype {
        .jump :: geng.audio.Buffer,
        .hit :: geng.audio.Buffer,
        .pickup_star :: geng.audio.Buffer,
    };

    const Textures = newtype {
        .fullscreen :: ugli.Texture,
        .mute :: ugli.Texture,
        .muted :: ugli.Texture,
    };

    const Models = newtype {
        .unicorn :: Model.t,
    };

    const load = () -> t => (
        (#
    let music = geng.audio.load("assets/music.wav");
    geng.audio.play_with(
        music,
        {
            .@"loop" = true,
            .gain = 2,
        },
    );
    #) let sfx = {
            .jump = geng.audio.load("assets/sfx/jump.wav"),
            .hit = geng.audio.load("assets/sfx/hit.wav"),
            .pickup_star = geng.audio.load("assets/sfx/pickup_star.wav"),
        };
        let font = font.Font.load("assets/font");

        let shaders = {
            .model = geng.load_shader("assets/shaders/model"),
        };

        let load_texture = path => geng.load_texture("assets/textures/" + path, :Nearest);

        let textures = {
            .fullscreen = load_texture("fullscreen.png"),
            .mute = load_texture("mute.png"),
            .muted = load_texture("muted.png"),
        };

        let models = {
            .unicorn = Model.load("assets/unicorn"),
        };

        {
            # .music,
            .sfx,
            .font,
            .shaders,
            .textures,
            .models,
        }
    );
);
