use (import "./lib/_lib.ks").*;
use (import "./model.ks").*;
const collisions = import "./collisions.ks";

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

    const Ctx = @context t;

    const Shaders = newtype {
        .model :: ugli.Program,
    };

    const Sfx = newtype {
        .deflation :: geng.audio.Buffer,
        .inflation :: geng.audio.Buffer,
        .jetpack :: geng.audio.Buffer,
        .ground :: geng.audio.Buffer,
    };

    const Textures = newtype {
        .fullscreen :: ugli.Texture,
        .mute :: ugli.Texture,
        .muted :: ugli.Texture,
        .ground :: ugli.Texture,
        .water :: ugli.Texture,
    };

    const LevelModel = newtype {
        .collision_mesh :: collisions.Mesh,
        .model :: Model.t,
        .sfx :: geng.audio.Buffer,
    };

    impl LevelModel as module = (
        module:

        const load = (path :: String) -> LevelModel => (
            let mut collision_mesh = ArrayList.new();
            let obj = obj.parse(std.fs.read_file(path + "/model.obj"));
            for face in obj |> ArrayList.into_iter do (
                let mut mesh_face = {
                    .vs = ArrayList.new(),
                    .normal = Vec3.normalize(
                        Vec3.cross(
                            Vec3.sub(face.1.a_pos, face.0.a_pos),
                            Vec3.sub(face.2.a_pos, face.0.a_pos),
                        )
                    ),
                };
                &mut mesh_face.vs |> ArrayList.push_back(face.0.a_pos);
                &mut mesh_face.vs |> ArrayList.push_back(face.1.a_pos);
                &mut mesh_face.vs |> ArrayList.push_back(face.2.a_pos);
                &mut collision_mesh |> ArrayList.push_back(mesh_face);
            );
            {
                .collision_mesh = collisions.Mesh.new(collision_mesh),
                .model = Model.load(path),
                .sfx = geng.audio.load(path + "/sfx.wav"),
            }
        );
    );

    const Models = newtype {
        .skins :: ArrayList.t[Model.t],
        .level :: ArrayList.t[LevelModel],
        .jetpack :: Model.t,
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
            .deflation = geng.audio.load("assets/sfx/deflation.wav"),
            .inflation = geng.audio.load("assets/sfx/inflation.wav"),
            .jetpack = geng.audio.load("assets/sfx/jetpack.wav"),
            .ground = geng.audio.load("assets/sfx/ground.wav"),
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
            .ground = (
                let mut texture = geng.load_texture("assets/textures/ground.png", :Nearest);
                &mut texture |> ugli.Texture.set_wrap(:Repeat);
                texture
            ),
            .water = (
                let mut texture = geng.load_texture("assets/textures/water.png", :Nearest);
                &mut texture |> ugli.Texture.set_wrap(:Repeat);
                texture
            ),
        };

        let models = {
            .skins = (
                let mut list = ArrayList.new();
                &mut list |> ArrayList.push_back(Model.load("assets/models/player/fish"));
                &mut list |> ArrayList.push_back(Model.load("assets/models/player/unicorn"));
                &mut list |> ArrayList.push_back(Model.load("assets/models/player/daivy"));
                &mut list |> ArrayList.push_back(Model.load("assets/models/player/fart"));
                &mut list |> ArrayList.push_back(Model.load("assets/models/player/pgorley"));
                list
            ),
            .level = (
                let mut list = ArrayList.new();
                &mut list |> ArrayList.push_back(LevelModel.load("assets/models/level/grass"));
                &mut list |> ArrayList.push_back(LevelModel.load("assets/models/level/lava"));
                &mut list |> ArrayList.push_back(LevelModel.load("assets/models/level/logs"));
                &mut list |> ArrayList.push_back(LevelModel.load("assets/models/level/rock"));
                &mut list |> ArrayList.push_back(LevelModel.load("assets/models/level/sand"));
                &mut list |> ArrayList.push_back(LevelModel.load("assets/models/level/ice"));
                list
            ),
            .jetpack = Model.load("assets/models/jetpack"),
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
