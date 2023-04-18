typedef int ssize_t;
typedef unsigned int size_t;

int get_len(int fd);
ssize_t read(int fildes, void *buf, size_t nbyte);
int get_input(int fd);
void buffer_overflow(int fd) {
  int len;
  char buf[128];

  len = get_input(fd);
  if (len > 128) {
    return;
  }

  read(fd, buf, len);
}