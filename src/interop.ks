use (import "./lib/la/_lib.ks").*;
use std.collections.OrdMap;

module:

const Id = Int32;

const PlayerState = newtype {
    .pos :: Vec3,
};

const ServerMessage = newtype (
    | :Connected Id
    | :Disconnected Id
    | :UpdatePlayer { .id :: Id, .state :: PlayerState }
    | :RequestUpdate
);

const ClientMessage = newtype (
    | :Update PlayerState
);
