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
        .jump :: geng.audio.Buffer,
        .hit :: geng.audio.Buffer,
        .pickup_star :: geng.audio.Buffer,
    };

    const Textures = newtype {
        .fullscreen :: ugli.Texture,
        .mute :: ugli.Texture,
        .muted :: ugli.Texture,
        .ground :: ugli.Texture,
    };

    const LevelModel = newtype {
        .collision_mesh :: collisions.Mesh,
        .model :: Model.t,
    };

    impl LevelModel as module = (
        module:

        const load = (path :: String) -> LevelModel => (
            let mut collision_mesh = { .faces = ArrayList.new() };
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
                &mut collision_mesh.faces |> ArrayList.push_back(mesh_face);
            );
            {
                .collision_mesh,
                .model = Model.load(path),
            }
        );
    );

    const Models = newtype {
        .skins :: ArrayList.t[Model.t],
        .level :: LevelModel,
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
            .ground = (
                let mut texture = geng.load_texture("assets/textures/ground.png", :Nearest);
                &mut texture |> ugli.Texture.set_wrap(:Repeat);
                texture
            ),
        };

        let models = {
            .skins = (
                let mut list = ArrayList.new();
                &mut list |> ArrayList.push_back(Model.load("assets/models/unicorn"));
                &mut list |> ArrayList.push_back(Model.load("assets/models/daivy"));
                list
            ),
            .level = LevelModel.load("assets/models/level"),
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
