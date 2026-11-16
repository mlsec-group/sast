#include <stdio.h>

/* Triggers: Semgrep (insecure gets), RATS (gets buffer overflow). */
int main(void)
{
	char buf[64];

	gets(buf);
	printf("%s", buf);
	return 0;
}
