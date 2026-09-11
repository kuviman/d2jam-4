#include <netdb.h>
#include <stdbool.h>
#include <stdio.h>
#include <stdlib.h>
#include <stdnoreturn.h>
#include <string.h>
#include <sys/socket.h>

noreturn void panic(const char *s) {
  fprintf(stderr, "panic: %s\n", s);
  exit(-1);
}
noreturn void panic_errno(const char *s) {
  fprintf(stderr, "%s\n", s);
  exit(-1);
}

typedef struct {
  int sock_fd;
  FILE *reader;
  FILE *writer;
} tcp_Stream;

tcp_Stream tcp_Stream_from_fd(int fd) {
  FILE *reader = fdopen(fd, "r");
  if (!reader) {
    panic_errno("tcp_Stream_from_fd");
  }
  FILE *writer = fdopen(fd, "w");
  if (!writer) {
    panic_errno("tcp_Stream_from_fd");
  }
  return (tcp_Stream){
      .sock_fd = fd,
      .reader = reader,
      .writer = writer,
  };
}

const char *Kast_read_until(FILE *f, char c) {
  char *buf = NULL;
  size_t buf_size = 0;
  ssize_t length = getdelim(&buf, &buf_size, c, f);
  if (length < 0) {
    panic_errno("Kast_read_until.getdelim");
  }
  return buf;
}

const char *tcp_Stream_read_line(tcp_Stream *s) {
  return Kast_read_until(s->reader, '\n');
}

tcp_Stream tcp_Stream_connect(const char *host, const char *port) {
  struct addrinfo *ai, *rp;
  int res = getaddrinfo(host, port, NULL, &ai);
  if (res) {
    if (res == EAI_SYSTEM) {
      panic_errno("tcp_Stream_connect.getaddrinfo");
    } else {
      fprintf(stderr, "getaddrinfo failed with %d", res);
      exit(-1);
    }
  }
  for (rp = ai; rp != NULL; rp = rp->ai_next) {
    if (rp->ai_socktype != SOCK_STREAM) {
      continue;
    }
    int sock_fd = socket(rp->ai_family, rp->ai_socktype, rp->ai_protocol);
    if (sock_fd == -1) {
      panic_errno("tcp_Stream_connect.socket");
    }
    printf("trying to connect\n");
    int res = connect(sock_fd, rp->ai_addr, rp->ai_addrlen);
    if (res == 0) {
      freeaddrinfo(ai);
      return tcp_Stream_from_fd(sock_fd);
    };
    // ignore errno, try next addr
  }
  freeaddrinfo(ai);
  panic("failed to connect");
}

void tcp_Stream_write(tcp_Stream *s, const char *data) {
  fprintf(s->writer, "%s", data);
  if (fflush(s->writer) != 0) {
    panic_errno("tcp_Stream_write.fflush");
  }
}

int main() {
  tcp_Stream stream = tcp_Stream_connect("localhost", "1234");
  printf("Connected\n");
  while (true) {
    const char *msg = tcp_Stream_read_line(&stream);
    printf("server said: %s\n", msg);
    tcp_Stream_write(&stream, "{\"tag\":\"Update\",\"data\":{\"position\":{"
                              "\"0\":0,\"1\":1,\"2\":2}}}\n");
  }
  return 0;
}
