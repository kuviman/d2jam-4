const State = newtype {
    .next_id :: interop.Id,
    .players :: OrdMap.t[interop.Id, interop.PlayerState],
};

const ClientState = newtype {
    .id :: interop.Id,
    .disconnected :: () -> Never,
    .send :: interop.ServerMessage -> (),
    .known_players :: OrdSet.t[interop.Id],
};

impl State as module = (
    module:
    const init = () -> State => {
        .next_id = 0,
        .players = OrdMap.new(),
    };
);

const on_connect = (
    state :: &mut State,
    client :: &mut ClientState,
) => (
    client^.send(:RequestUpdate);
);

const handle_client_message = (
    state :: &mut State,
    client :: &mut ClientState,
    msg :: interop.ClientMessage,
) => (
    match msg with (
        | :Update player_state => (
            &mut state^.players |> OrdMap.add(client^.id, player_state);
            let mut new_known_players = OrdSet.new();
            for &{ .key = id, .value = other_player_state } in &state^.players |> OrdMap.iter do (
                if id != client^.id then (
                    if not (&client^.known_players |> OrdSet.contains(id)) then (
                        client^.send(:Connected id);
                    );
                    &mut new_known_players |> OrdSet.add(id);
                    client^.send(:UpdatePlayer { .id, .state = other_player_state });
                );
            );
            for &id in &client^.known_players |> OrdSet.iter do (
                if not (&new_known_players |> OrdSet.contains(id)) then (
                    client^.send(:Disconnected id);
                );
            );
            client^.known_players = new_known_players;
            client^.send(:RequestUpdate);
        )
    );
);
