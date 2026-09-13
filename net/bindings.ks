use (import "../src/lib/_lib.ks").*;

module:

const init = (address :: String) => (
    @native "#include <net/client.h>";
    @native "badcop_init(String_to_C_String(\(address)))";
);

const PlayerData = newtype {
    .position :: Vec3,
    .velocity :: Vec3,
    .rotation :: Quat,
    .skin :: Int32,
    .jetpack :: Bool,
};

const send_update = (u :: PlayerData) => (
    @native ''
        badcop_send_update((ClientMsgUpdate) {
            .px = \(u.position.0),
            .py = \(u.position.1),
            .pz = \(u.position.2),
            .vx = \(u.velocity.0),
            .vy = \(u.velocity.1),
            .vz = \(u.velocity.2),
            .rx = \(u.rotation.i),
            .ry = \(u.rotation.j),
            .rz = \(u.rotation.k),
            .rw = \(u.rotation.w),
            .skin = \(u.skin),
            .jetpack = \(if u.jetpack then 1 else 0),
        })
    '';
);

const Id = Int64;

const ServerMessage = newtype (
    | :Connected Id
    | :Disconnected Id
    | :UpdatePlayer {
        .id :: Id,
    }
);

const poll_message = () -> Option.t[ServerMessage] => with_return (
    let msg :: @opaque_type "void*" = @native "badcop_poll_msg()";
    if @native "\(msg) == NULL" then (
        return :None;
    );
    let tag :: @opaque_type "ServerMsgTag" = @native "*((ServerMsgTag*)\(msg))";
    let data :: @opaque_type "void*" = @native "\(msg) + sizeof(ServerMsgTag)";
    if @native "\(tag) == ServerUpdatePlayer" then (
        let data :: @opaque_type "ServerMsgUpdatePlayer*" = @native "\(data)";
        return :Some :UpdatePlayer {
        };
    );
    if @native "\(tag) == ServerConnected" then (
        return :Some :Connected;
    );
    if @native "\(tag) == ServerDisconnected" then (
        return :Some :Disconnected;
    );
    panic("Unrecognized tag in server message")
);
