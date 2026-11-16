#include <stdlib.h>
#include <string.h>

/* Triggers: Semgrep (unchecked malloc return). */
int main(void)
{
	char *p = (char *)malloc(256);

	memset(p, 'A', 256);
	return 0;
}
