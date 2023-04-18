typedef int myint;
typedef unsigned int myuint;
using myotherint = int;
using myotheruint = unsigned int;
void test() {
  char a;
  signed char b;
  unsigned char c;
  short d;
  signed short e;
  unsigned short f;
  int g;
  signed int h;
  unsigned int i;

  myint j;
  myotherint k;

  myuint l;
  myotheruint m;

  const int n = 1;
  const myint o = 2;
  const myotherint p = 3;
  const unsigned int q = 4;
  const myuint r = 5;
  const myotheruint s = 6;
}