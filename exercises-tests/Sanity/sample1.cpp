int get_input(int fd);
using size_t = unsigned int;
size_t read(int fildes, void *buf, size_t nbyte);

void buffer_overflow(int fd) {
	int len;
	char buf[128];

	len = get_input(fd);
	if (len > 128) {
		return;
	}

	read(fd, buf, len);
}
