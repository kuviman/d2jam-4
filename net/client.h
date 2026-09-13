/*
 * Copyright 2018 Markus Lindelöw
 *
 * Permission is hereby granted, free of charge, to any person obtaining a copy
 * of this software and associated documentation files(the "Software"), to deal
 * in the Software without restriction, including without limitation the rights
 * to use, copy, modify, merge, publish, distribute, sublicense, and / or sell
 * copies of the Software, and to permit persons to whom the Software is
 * furnished to do so, subject to the following conditions:
 *
 * The above copyright notice and this permission notice shall be included in all
 * copies or substantial portions of the Software.
 *
 * THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
 * IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
 * FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT.IN NO EVENT SHALL THE
 * AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
 * LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
 * OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE
 * SOFTWARE.
 */


/*
  init -> setup
  sends message to server
  receiving message from server


  broadcast to all sockets
*/


#define TINYCSOCKET_IMPLEMENTATION
#include "tinycsocket.h"
#include "interop.h"

#include <stdbool.h>
#include <stdio.h>
#include <stdlib.h>
#include <string.h>

int show_error(const char* error_text)
{
    fprintf(stderr, "%s\n", error_text);
    return -1;
}

int connected = 0;

#define RECV_BUFSIZE 1024
typedef struct UserData {
  size_t start;
  size_t end;
  uint8_t buf[RECV_BUFSIZE];
} UserData;

void * has_full_message(UserData* user, size_t n, int* looping) {
  if (user->end < user->start + n + 4) {
    if (looping != NULL) {
      *looping = 0;
    }
    return NULL;
  }
  void *ret = user->buf + user->start;
  user->start += n + 4;
  return ret;
}

struct TcsPoll* tcs_poll = NULL;
TcsSocket client_socket = TCS_SOCKET_INVALID;
UserData user = {};
struct TcsPollEvent ev[1] = {};

TcsResult badcop_send_update(ClientMsgUpdate update) {
      struct __attribute__((packed)) {
      ClientMsgTag tag;
      ClientMsgUpdate data;
    } msg = {
      .tag = ClientUpdate,
      .data = update
    };
    TcsResult res = tcs_send(client_socket, (const uint8_t*)&msg, sizeof(msg), TCS_MSG_SENDALL, NULL);
    if (res != TCS_SUCCESS) {
      connected = 0;
    }
    return res;
}

TcsResult badcop_set_name(const char *name) {
      struct __attribute__((packed)) {
      ClientMsgTag tag;
      ClientMsgSetName data;
    } msg = {
      .tag = ClientSetName,
      .data = {0},
    };
    strncpy(msg.data.name, name, MAX_NAME_LEN);
    TcsResult res = tcs_send(client_socket, (const uint8_t*)&msg, sizeof(msg), TCS_MSG_SENDALL, NULL);
    if (res != TCS_SUCCESS) {
      connected = 0;
    }
    return res;
}

TcsResult badcop_beat_game(unsigned long long duration) {
      struct __attribute__((packed)) {
      ClientMsgTag tag;
      ClientMsgBeatGame data;
    } msg = {
      .tag = ClientBeatGame,
      .data = { .duration = duration },
    };
    TcsResult res = tcs_send(client_socket, (const uint8_t*)&msg, sizeof(msg), TCS_MSG_SENDALL, NULL);
      if (res != TCS_SUCCESS) {
      connected = 0;
    }
    return res;
}

/***
 * Read from the actual TCP socket; don't call this directly (see 'poll_msg')
 */
void _recv_next() {
  size_t events;
  TcsResult poll_res = tcs_poll_wait(tcs_poll, ev, 1, &events, 0);
  if (events && ev[0].can_read)
  {
      size_t received_size = 0;
      TcsResult res = tcs_receive(client_socket, user.buf + user.end, RECV_BUFSIZE - user.end, TCS_FLAG_NONE, &received_size);
      switch (res) {
        case TCS_SUCCESS:
          user.end += received_size;
          break;
        case TCS_ERROR_WOULD_BLOCK:
        break;
        default:
          connected = 0;
          break;
      }
  }
}

/***
 * Get one message from the server.
 * Returns NULL if there are no more messages available.
 */
void *badcop_poll_msg() {
    if (user.start == user.end) {
      _recv_next();
    }
    if (user.start <= user.end + 4) {
      void *msg;
      switch(user.buf[user.start]) {
        case ServerUpdatePlayer:
          if (msg = has_full_message(&user, sizeof(ServerMsgUpdatePlayer), NULL))
            return msg;
          break;
        case ServerConnected:
          if (msg = has_full_message(&user, sizeof(ServerMsgConnected), NULL))
            return msg;
          break;
        case ServerPlayerMeta:
          if (msg = has_full_message(&user, sizeof(ServerMsgPlayerMeta), NULL))
            return msg;
          break;
        case ServerDisconnected:
          if (msg = has_full_message(&user, sizeof(ServerMsgDisconnected), NULL))
            return msg;
          break;
      }
    }
    // reset buffer 
    if (user.start == user.end) {
      user.start = 0;
      user.end = 0;
    }
    // shift remaining garbage to the front of the buffer
    else if (user.start && user.start < user.end) {
      memmove(user.buf,  user.buf + user.start, user.end - user.start);
      user.end = user.end - user.start;
      user.start = 0;
    }
    return NULL;
}

/***
 * Call to open a socket to the server.
 */
int badcop_init(char *conn_str)
{
    if (tcs_lib_init() != TCS_SUCCESS)
        return show_error("Could not init tinycsocket");   

    if (tcs_socket_tcp_str(&client_socket, NULL, conn_str, 1000) != TCS_SUCCESS)
        return show_error("Could not create a socket");

    connected = 1;

    #ifndef __EMSCRIPTEN__
    tcs_opt_nonblocking_set(client_socket, true);
    tcs_opt_ip_no_delay_set(client_socket, true);
    #endif

    tcs_poll_create(&tcs_poll);
    tcs_poll_add(tcs_poll, client_socket, NULL, TCS_POLL_READ);
}

/***
 * don't call this why would you ever do that
 */
int cleanup() {
    if (tcs_shutdown(client_socket, TCS_SHUTDOWN_BOTH) != TCS_SUCCESS)
        return show_error("Could not shutdown socket");

    if (tcs_close(&client_socket) != TCS_SUCCESS)
        return show_error("Could not close the socket");

    if (tcs_lib_cleanup() != TCS_SUCCESS)
        return show_error("Could not free tinycsocket");
}
