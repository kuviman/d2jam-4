use std.net.tcp;
use std.collections.OrdMap;
use std.collections.OrdSet;
const interop = import "./interop.ks";
const json = import "./json.ks";
use std.sync.Mutex;

module:

include "./server_logic.ks";

const ClientCtx = @context ClientState;

const read_line = (stream :: &mut tcp.Stream) -> String => (
    let mut buf :: @opaque_type "char*" = @native "NULL";
    let mut buf_size :: @opaque_type "size_t" = @native "0";
    let length :: @opaque_type "ssize_t" = @native ''
        getdelim(\(&mut buf), \(&mut buf_size), '\\n', \(stream)->reader)
    '';
    if @native "\(length) < 0" then (
        if @native "feof(\(stream)->reader)" then (
            (@current ClientCtx).disconnected();
        );
        @native "panic_errno(\"getdelim\")";
    );
    buf = @native "Kast_ensure_correct_malloc(\(buf), \(length))";
    let line :: String = @native ''
        (String) {
            .buf = \(buf),
            .length = \(length),
        }
    '';
    # @native "GC_gcollect()";
    line
);

const handle_client = (server_state, mut client) => (
    std.io.print <| "New client connected: " + client.addr;
    with_return (
        let send = msg => (
            let msg = include_ast json.construct_value(`(msg), interop.ServerMessage);
            let msg = to_string(msg);
            # print("sending to " + client.addr + ": " + msg);
            tcp.Stream.write(&mut client.stream, &(msg + "\n"));
        );
        let state = Mutex.lock(server_state);
        let id = state.value^.next_id;
        state.value^.next_id += 1;
        with ClientCtx = {
            .id,
            .send,
            .disconnected = () => return,
            .known_players = OrdSet.new(),
        };
        let error = (s :: String) -> Never => (
            print <| "Client error (" + client.addr + "): " + s;
            return
        );
        on_connect(state.value, &mut (@current ClientCtx));
        Mutex.unlock(state);
        loop (
            let msg = read_line(&mut client.stream);
            # std.io.print <| "from " + client.addr + ": " + msg;
            let msg = match json.parse(&mut json.Reader.create(&msg)) with (
                | :Ok msg => msg
                | :Error _ => error("Failed to parse json") |> from_never
            );
            let msg = include_ast json.parse_value(`(msg), interop.ClientMessage);
            let state = Mutex.lock(server_state);
            handle_client_message(state.value, &mut (@current ClientCtx), msg);
            Mutex.unlock(state);
        );
    );
    std.io.print <| "Client disconnected: " + client.addr;
    client.stream |> tcp.Stream.close;
);

const run = (address :: String) => (
    print("Starting server on " + address);
    let mut listener = tcp.Listener.bind(address);
    tcp.Listener.listen(&mut listener, 5);
    let server_state = State.init();
    let server_state = std.sync.Mutex.new(server_state);
    loop (
        print("Waiting for client to connect...");
        let client = tcp.Listener.accept(&mut listener, .close_on_exec = true);
        handle_client(&server_state, client);
    # std.thread.spawn(() => handle_client(&server_state, client));
    );
    listener |> tcp.Listener.close;
);
