use std.net.tcp;

module:

const handle_client = (mut client) => (
    std.io.print <| "New client connected " + client.addr;
    let client_msg = tcp.Stream.read_line(&mut client.stream);
    std.io.print <| "Client said:\n" + client_msg;
    tcp.Stream.write(
        &mut client.stream,
        &"Hello from server\n"
    );
    client.stream |> tcp.Stream.close;
);

const run = (address :: String) => (
    let mut listener = tcp.Listener.bind(address);
    tcp.Listener.listen(&mut listener, 5);
    let client = tcp.Listener.accept(&mut listener, .close_on_exec = true);
    handle_client(client);
    listener |> tcp.Listener.close;
);
