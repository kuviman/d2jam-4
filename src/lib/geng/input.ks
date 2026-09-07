use (import "../common.ks").*;
use (import "../la/_lib.ks").*;
const SDL = import "../sdl3/_lib.ks";

use std.collections.Queue;

module:

const ContextT = newtype {
    .events :: Queue.t[Event],
};
const Context = @context ContextT;

const init = () -> ContextT => (
    let mut events = Queue.new();
    {
        .events,
    }
);

const Key = newtype (
    | :ArrowLeft
    | :ArrowRight
    | :ArrowUp
    | :ArrowDown
    | :Space
);

impl Key as module = (
    module:

    const is_pressed = (key :: Key) -> Bool => (
        # TODO
        false
    );
);

const MouseButton = newtype (
    | :Left
    | :Middle
    | :Right
);

impl MouseButton as module = (
    module:

    const from_raw = (raw :: Int32) -> Option.t[MouseButton] => (
        if raw == 0 then (
            :Some (:Left)
        ) else if raw == 1 then (
            :Some (:Middle)
        ) else if raw == 2 then (
            :Some (:Right)
        ) else (
            :None
        )
    );

    const into_raw = (button :: MouseButton) -> Int32 => (
        match button with (
            | :Left => 0
            | :Middle => 1
            | :Right => 2
        )
    );

    const is_pressed = (button :: MouseButton) -> Bool => (
        # TODO
        false
    );
);

const Event = newtype (
    | :MousePress { .button :: MouseButton }
    | :PointerPress { .pos :: Vec2 }
    | :Quit
);

const convert = (event :: SDL.Event) -> Option.t[Event] => with_return (
    if @native "\(event).type == SDL_EVENT_MOUSE_BUTTON_DOWN" then (
        let pos :: Vec2 = { @native "\(event).button.x", @native "\(event).button.y" };
        let window_size = geng.get_window_size();
        let pos = { pos.0, window_size.1 - 1 - pos.1 };
        return :Some :PointerPress { .pos };
        let button = if @native "\(event).button.button == SDL_BUTTON_LEFT" then (
            :Left
        ) else if @native "\(event).button.button == SDL_BUTTON_MIDDLE" then (
            :Middle
        ) else if @native "\(event).button.button == SDL_BUTTON_RIGHT" then (
            :Right
        ) else (
            return :None
        );
        :Some :MousePress { .button }
    ) else if @native "\(event).type == SDL_EVENT_QUIT" then (
        :Some :Quit
    ) else (
        :None
    )
);

const iter_events = () -> std.iter.Iterable[Event] => (
    let mut ctx = (@current Context);
    {
        .iter = consumer => (
            while SDL.PollEvent() is :Some sdl_event do (
                if convert(sdl_event) is :Some event then (
                    consumer(event);
                );
            );
        ),
    }
);

const is_any_pointer_pressed = () -> Bool => (
    @native "SDL_GetMouseState(NULL, NULL) != 0"
);
