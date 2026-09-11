const server = (
    use std.net.tcp;
    use std.sync.Mutex;

    module:

    const ClientState = newtype {
        .send :: String -> (),
        .disconnected :: () -> Never,
    };

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

    const handle_client = (mut client) => (
        std.io.print <| "New client connected: " + client.addr;
        with_return (
            let send = msg => (
                print("sending to " + client.addr + ": " + msg);
                tcp.Stream.write(&mut client.stream, &(msg + "\n"));
            );
            with ClientCtx = {
                .send,
                .disconnected = () => return,
            };
            let error = (s :: String) -> Never => (
                print <| "Client error (" + client.addr + "): " + s;
                return
            );
            send("hi from server");
            loop (
                std.thread.sleep_ns(1000000000);
                let msg = read_line(&mut client.stream);
                std.io.print <| "from " + client.addr + ": " + msg;
                send("reply from server");
            );
        );
        std.io.print <| "Client disconnected: " + client.addr;
        client.stream |> tcp.Stream.close;
    );

    const run = (address :: String) => (
        print("Starting server on " + address);
        let mut listener = tcp.Listener.bind(address);
        tcp.Listener.listen(&mut listener, 5);
        loop (
            print("Waiting for client to connect...");
            let client = tcp.Listener.accept(&mut listener, .close_on_exec = true);
            std.thread.spawn(() => handle_client(client));
        );
        listener |> tcp.Listener.close;
    );
);

server.run("localhost:1234");
