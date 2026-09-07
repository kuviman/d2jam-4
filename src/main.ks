use (import "lib/_lib.ks").*;
use (import "./assets.ks").*;

module:

const Game = newtype {
    .assets :: Assets.t,
};

@eval (
    impl Game as geng.App = {
        .init = () => {
            .assets = Assets.load(),
        },
        .draw = self => (),
        .update = (self, delta_time) => (),
        .handle_event = (self, event) => (),
    }
);

geng.run[Game]();
