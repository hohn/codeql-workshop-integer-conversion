char *out_of_bounds(char *c, int n) {
  char *ptr = c + n;
  return ptr;
}

#define INT_MAX 2147483648

int main(void) {
  unsigned int n = INT_MAX + 1;
  char buf[1024];
  char *ptr = out_of_bounds(buf, n);
}