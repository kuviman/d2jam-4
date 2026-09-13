typedef enum ServerMsgTag {
  ServerUpdatePlayer,
  ServerConnected,
  ServerDisconnected,
  ServerRequestUpdate
} ServerMsgTag;


typedef enum ClientMsgTag {
  ClientUpdate
} ClientMsgTag;

typedef struct __attribute__((packed)) {
  unsigned long long id;
} ServerMsgConnected;

typedef struct __attribute__((packed)) {
  unsigned long long id;
} ServerMsgDisconnected;

typedef struct __attribute__((packed)) {
} ServerMsgRequestUpdate;

typedef struct __attribute__((packed)) {
  float px;
  float py;
  float pz;
  float vx;
  float vy;
  float vz;
  float rx;
  float ry;
  float rz;
  float rw;
  int skin;
  int jetpack;
} ClientMsgUpdate;

typedef struct __attribute__((packed)) {
  unsigned long long id;
  ClientMsgUpdate stuff;
} ServerMsgUpdatePlayer;

/*
////////////////////////////////////////////////////////////////////////////////
// Defining a type like this:

  typedef struct ServerMsg {
    ServerMsgTag tag;
    union {
      ServerMsgConnected connected;
      ServerMsgDisconnected disconnected;
      ServerMsgUpdatePlayer updatePlayer;
    } data;
  } ServerMsg;

// Would allow this in testclient.c `handle_message`:

  ServerMsg *serverMsg = (ServerMsg *)msg;
  switch (serverMsg->tag) {
    case ServerUpdatePlayer: {
      ServerMsgUpdatePlayer *update = serverMsg->data.updatePlayer;
  }

////////////////////////////////////////////////////////////////////////////////
// could also do this:

ServerMsgTag tag = *((ServerMsgTag*)msg);
void *data = msg + sizeof(ServerMsgTag);

  case:
    ServerMsgUpdatePlayer *update = (ServerMsgUpdatePlayer*)data;

////////////////////////////////////////////////////////////////////////////////
*/