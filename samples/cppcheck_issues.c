#include <stdlib.h>

/* Triggers: cppcheck (--enable=all): leak, uninit, div by zero, null deref paths. */

int leaky(void)
{
	void *p = malloc(32);
	(void)p;
	return 0;
}

int uninit_and_div(void)
{
	int x;
	int zero = 0;
	return x / zero;
}

int maybe_null_deref(int *p)
{
	*p = 42;
	return 0;
}

int main(void)
{
	(void)leaky();
	(void)uninit_and_div();
	(void)maybe_null_deref(NULL);
	return 0;
}
