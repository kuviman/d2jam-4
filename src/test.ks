const client = import "./client.ks";
const cli = import "./cli.ks";

let args = cli.parse();
if args.server is :Some address then (
    const server = import "./server.ks";
    let run = () => server.run(address);
    match args.connect with (
        | :None => (
            run();
        )
        | :Some _ => (
            std.thread.spawn(run);
        )
    );
);
if args.connect is :Some address then (
    let c = client.connect(address);
    with client.Ctx = c;
    loop (
        while client.poll_message() is :Some msg do (
            match msg with (
                | :RequestUpdate => (
                    print("requested update");
                    client.send(:Update { .position = { 0, 0, 0 } });
                )
                | _ => ()
            )
        );
    )
);
