#include <cassert>

int add(int lhs, int rhs) { return lhs + rhs; }

int main()
{
  assert(add(2, 3) == 5);
  return 0;
}
