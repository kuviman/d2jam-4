module:

const Args = newtype {
    .server :: Option.t[String],
    .connect :: Option.t[String],
};

const parse = () -> Args => (
    let mut result :: Args = {
        .server = :None,
        .connect = :None,
    };
    let mut i = 1;
    while i < std.sys.argc() do (
        let arg = std.sys.argv_at(i);
        if arg == "--server" then (
            let address = std.sys.argv_at(i + 1);
            result.server = :Some address;
            i += 2;
            continue;
        );
        if arg == "--connect" then (
            let address = std.sys.argv_at(i + 1);
            result.connect = :Some address;
            i += 2;
            continue;
        );
        panic("Unexpected arg " + arg);
    );
    if { result.server, result.connect } is { :None, :None } then (
        result.connect = :Some "TODO setup default server";
    );
    result
);
