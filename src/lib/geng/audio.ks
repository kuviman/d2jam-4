const asset = import "./asset.ks";
const SDL = import "../sdl3/_lib.ks";

module:

const ContextT = newtype {
    .mixer :: SDL.MIX.Mixer,
};

const Context = @context ContextT;

const init = () -> ContextT => (
    SDL.MIX.Init();
    let mixer = SDL.MIX.CreateMixerDevice(
        @native "SDL_AUDIO_DEVICE_DEFAULT_PLAYBACK",
        @native "NULL",
    );
    { .mixer }
);

const PlayOptions = newtype {
    .@"loop" :: Bool,
    .gain :: Float32,
};

impl PlayOptions as module = (
    module:

    const default = () -> PlayOptions => {
        .@"loop" = false,
        .gain = 1,
    };
);

const play_with = (buffer :: Buffer, options :: PlayOptions) -> () => (
    let ctx = (@current Context);
    let track = SDL.MIX.CreateTrack(ctx.mixer);
    SDL.MIX.SetTrackAudio(track, buffer.audio);
    SDL.MIX.SetTrackGain(track, options.gain);
    # This one doesnt work
    # SDL.MIX.SetTrackLoops(track, if options.@"loop" then (-1) else 0);
    let props = SDL.CreateProperties();
    if options.@"loop" then (
        SDL.SetNumberProperty(props, @native "MIX_PROP_PLAY_LOOPS_NUMBER", -1);
    );
    SDL.MIX.PlayTrack(track, props);
    SDL.DestroyProperties(props);
);

const play = (buffer :: Buffer) => (
    play_with(buffer, PlayOptions.default())
);

const set_master_volume = (volume :: Float32) -> () => (
    let ctx = (@current Context);
    SDL.MIX.SetMixerGain(ctx.mixer, volume);
);

const Buffer = newtype {
    .audio :: SDL.MIX.Audio,
};

const load = (path) -> Buffer => (
    let ctx = (@current Context);
    let audio = SDL.MIX.LoadAudio(ctx.mixer, path, true);
    { .audio }
);

impl Buffer as asset.Load = {
    .load,
    .default_ext = :Some "wav",
};
