use (import "./lib/_lib.ks").*;
const interop = import "./interop.ks";
const json = import "./json.ks";
use std.net.tcp;

module:

const State = newtype {
    .name :: String,
    .stream :: tcp.Stream,
};

const Ctx = @context State;

const poll_read_line = () -> Option.t[String] => with_return (
    let ctx = @current Ctx;
    let mut buf :: @opaque_type "char*" = @native "NULL";
    let mut buf_size :: @opaque_type "size_t" = @native "0";
    let length :: @opaque_type "ssize_t" = @native ''
        getdelim(\(&mut buf), \(&mut buf_size), '\\n', \(ctx.stream).reader)
    '';
    if @native "\(length) < 0" then (
        if @native "errno == EAGAIN || errno == EWOULDBLOCK" then (
            return :None;
        ) else if @native "feof(\(ctx.stream).reader)" then (
            panic("Server closed connection");
        ) else (
            @native "panic_errno(\"getdelim\")";
        );
    );
    buf = @native "Kast_ensure_correct_malloc(\(buf), \(length))";
    let line :: String = @native ''
        (String) {
            .buf = \(buf),
            .length = \(length),
        }
    '';
    # print("server said: " + line);
    :Some line
);

const poll_message = () -> Option.t[interop.ServerMessage] => (
    let line = poll_read_line();
    if not is_emscripten() then (
        # @native "GC_gcollect()";

    );
    match line with (
        | :None => :None
        | :Some msg => :Some (
            let msg = match json.parse(&mut json.Reader.create(&msg)) with (
                | :Ok msg => msg
                | :Error _ => panic("Failed to parse json")
            );
            include_ast json.parse_value(`(msg), interop.ServerMessage)
        )
    )
);

const send = (msg :: interop.ClientMessage) => (
    let value = include_ast json.construct_value(`(msg), interop.ClientMessage);
    let s = to_string(value);
    write_line(s);
);

const read_line = () -> String => with_return (
    @loop (
        if poll_read_line() is :Some line then (
            return line;
        );
        @native ''
            #ifdef __EMSCRIPTEN__
                emscripten_sleep(100)
            #else
                (Unit){}
            #endif
        '';
    )
);

const write_line = (line :: String) => (
    let mut ctx = @current Ctx;
    # print("sending to server: " + line);
    tcp.Stream.write(&mut ctx.stream, &(line + "\n"));
);

const connect = (address :: String) -> State => (
    let ctx = {
        .name = "CLIENT",
        .stream = tcp.Stream.connect(address),
    };
    if false and not is_emscripten() then (
        let fd :: @opaque_type "int" = @native "\(ctx.stream).sock_fd";
        @native "#include <fcntl.h>";
        @native ''
            fcntl(\(fd), F_SETFL, fcntl(\(fd), F_GETFL, 0) | O_NONBLOCK)
        '';
    );
    print("Connected to the server!");
    ctx
);
