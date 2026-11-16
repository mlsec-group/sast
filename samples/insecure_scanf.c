#include <stdio.h>

/* Triggers: Semgrep (insecure scanf width), RATS (scanf overflow class). */
int main(void)
{
	char buf[8];

	scanf("%s", buf);
	return 0;
}
