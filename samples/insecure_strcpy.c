#include <string.h>

/* Triggers: Semgrep (strcpy/strcat), RATS (unbounded strcpy). */
void copy_name(const char *name)
{
	char stack_buf[16];

	strcpy(stack_buf, name);
}

int main(void)
{
	copy_name("attacker-controlled-very-long-string-here");
	return 0;
}
