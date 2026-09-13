#include "client.h"

#include <stdbool.h>
#include <stdio.h>
#include <stdlib.h>
#include <string.h>

void handle_message(void *msg) {
    ServerMsgTag tag = *((ServerMsgTag*)msg);
    void *data = (msg + sizeof(ServerMsgTag));
    switch(tag) {
      case ServerUpdatePlayer: {
        ServerMsgUpdatePlayer *update = (ServerMsgUpdatePlayer*)data;
        printf("Player Update: %llu\n", update->id);
        break;
      }
      case ServerConnected: {
        ServerMsgConnected *connected = (ServerMsgConnected*)data;
        printf("Connected: %llu\n", connected->id);
        break;
      }
      case ServerDisconnected: {
        ServerMsgDisconnected *disconnected = (ServerMsgDisconnected*)data;
        printf("Disconnected: %llu\n", disconnected->id);
        break;
      }
    }
}

int main(void)
{

    fcntl (0, F_SETFL, O_NONBLOCK);
    char c = 0;

    badcop_init("127.0.0.1:8080");

    while (main) {
      if (read (0, &c, 1) && c == '\n') {
        c = 0;
        ClientMsgUpdate update = {
          .px = 5.0,
          .py = 10.0,
          .pz = -1.0,
        };
        TcsResult res = badcop_send_update(&update);
        if (res != TCS_SUCCESS) {
          return show_error("Failed to send to server");
        }
      }

      // drain messages
      void *msg = NULL;
      while(msg = badcop_poll_msg()) {
        handle_message(msg);
      }
    }
}
