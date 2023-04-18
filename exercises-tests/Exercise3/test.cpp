typedef int myint;
typedef unsigned int myuint;
using myotherint = int;
using myotheruint = unsigned int;

void foo(unsigned int);
void bar(myuint);
void baz(myotheruint);

void test() {
  unsigned int a = 1;
  myuint b = 2u;
  myotheruint c = a;

  int d = 1;

  foo(d);
  bar(d);
  baz(d);

  foo((unsigned int)d);
}