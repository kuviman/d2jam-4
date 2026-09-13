typedef enum ServerMsgTag {
  ServerUpdatePlayer,
  ServerConnected,
  ServerDisconnected,
  ServerPlayerMeta
} ServerMsgTag;

typedef enum ClientMsgTag { 
  ClientUpdate,
  ClientBeatGame,
  ClientSetName
 } ClientMsgTag;

typedef struct __attribute__((packed)) {
  unsigned long long id;
} ServerMsgConnected;

typedef struct __attribute__((packed)) {
  unsigned long long id;
} ServerMsgDisconnected;

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
  struct {
    float x;
    float y;
    float z;
  } angular_vel;
  int skin;
  int jetpack;
  float scale;
} ClientMsgUpdate;

typedef struct __attribute__((packed)) {
  unsigned long long duration;
} ClientMsgBeatGame;

#define MAX_NAME_LEN 27
typedef struct __attribute__((packed)) {
  char name[MAX_NAME_LEN + 1];
} ClientMsgSetName;

typedef struct __attribute__((packed)) {
  unsigned long long id;
  unsigned long long best_time;
  char name[MAX_NAME_LEN + 1];
} ServerMsgPlayerMeta;

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
