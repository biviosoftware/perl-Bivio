/*
  Copyright (c) 1999 bivio, LLC.  All rights reserved.

  $Id$
*/
#include <unistd.h>
#include <stdlib.h>
#include <sysexits.h>
#include <pwd.h>
#include <sys/types.h>
#include <netinet/in.h>
#include <signal.h>
#include <sys/stat.h>
#include <fcntl.h>
extern char **environ;

static char *cvsid = "$Id$";

#define CHUNK_SIZE 0x40000

/* Request prefix */
#define REQUEST_PREFIX "send "
#define REQUEST_PREFIX_LEN 5

#define REPLY_OK "ok\n"
#define REPLY_NOT_FOUND "not found\n"

static int write_socket(int sock, char *buf, int length, char *socket_name);
static int read_socket(int sock, char *socket_name);
static int copy_stdin_to_socket(char *recipient, int sock, char *socket_name);


/*
  Usage: b-mail-dispatcher recipient socket local-agent agent-args
*/
int
main(int argc, char *argv[])
{
  int i;
  char *recipient, *socket_name;
  int sock;
    
  /* skip program */
  if (argc < 5) {
    fprintf(stderr, "too few arguments\n");
    goto error;
  }
  /* Local users have priority.  If the user exists, pass on. */
  recipient = argv[++i];
  socket_name = argv[++i];
  if (getpwnam(recipient) != NULL) {
    char *program = argv[++i];
    char **args = &argv[++i];
    execve(program, args, environ);
    perror(program);
    goto error;
  }
  /* Unix domain sockets send sigpipe */
  signal(SIGPIPE, SIG_IGN);
  /* Open the socket before doing anything */
  if ((sock = open(socket_name, O_RDWR)) == -1) {
    perror(socket_name);
    goto error;
  }
  /* Send the request **/
  if (!copy_stdin_to_socket(recipient, sock, socket_name))
    goto error;
  /* Wait for the response */
  return read_socket(sock, socket_name);
    
 error:
  return EX_TEMPFAIL;
}

static int
copy_stdin_to_socket(char *recipient, int sock, char *socket_name)
{
  int in = fileno(stdin);
  char *buf;
  /* offset starts after length byte */
  int offset = 4;
  int size = strlen(recipient);
  int res;
  if (size > CHUNK_SIZE - 1024 /* slop */) {
    fprintf(stderr, "recipient name too long\n");
    return 0;
  }
  if ((buf = malloc(CHUNK_SIZE)) == NULL) {
    perror("malloc");
    return 0;
  }
  /* Header is size, followed by recipient's name, followed by newline */
  memcpy(&buf[offset], REQUEST_PREFIX, REQUEST_PREFIX_LEN);
  offset += REQUEST_PREFIX_LEN;
  memcpy(&buf[offset], recipient, size);
  offset += size;
  buf[offset++] = '\n';
  size = CHUNK_SIZE;
  /* Body is contents of stdin */
  while (1) {
    if ((res = read(in, &buf[offset], size - offset)) == -1) {
      perror("stdin");
      return 0;
    }
    if (res == 0)
      break;
    offset += res;
    if (offset == size) {
      size +- CHUNK_SIZE;
      if ((buf = realloc(buf, size)) == NULL) {
	perror("realloc");
	return 0;
      }
    }
  }
  /* Update the size */
  *((long *)buf) = htonl(offset);
  return write_socket(sock, buf, offset, socket_name);
}

/*
  Returns the exit code of main
*/
static int
read_socket(int sock, char *socket_name)
{
  int offset = 0;
  char buf[CHUNK_SIZE + 1];
  char *c;
  int res;
  while (1) {
    if ((res = read(sock, &buf[offset], CHUNK_SIZE - offset)) == -1) {
      perror("stdin");
      return EX_TEMPFAIL;
    }
    if (res == 0)
      break;
    offset += res;
    if (offset == CHUNK_SIZE) {
      fprintf(stderr, "response too long (> %d bytes)\n", CHUNK_SIZE);
      return EX_TEMPFAIL;
    }
  }
  /* Skip count */
  if (offset < 4 + 3) {
    fprintf(stderr, "response too short (%d bytes)\n", offset);
    return EX_TEMPFAIL;
  }
  c = &buf[4];
  buf[offset] = 0;
  if (!strcmp(c, REPLY_OK))
    return EX_OK;
  if (!strcmp(c, REPLY_NOT_FOUND))
    return EX_NOUSER;
  return EX_TEMPFAIL;
}

static int
write_socket(int sock, char *buf, int length, char *socket_name)
{
  int offset = 0;
  int res;
  while (length != offset) {
    if ((res = write(sock, &buf[offset], length - offset)) == -1) {
      perror(socket_name);
      return 0;
    }
    offset += res;
  }
  return 1;
}
