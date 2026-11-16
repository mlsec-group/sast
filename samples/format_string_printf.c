#include <stdio.h>

/* Triggers: Semgrep (format string), often RATS on printf with tainted format. */
void log_user_message(char *user_text)
{
	printf(user_text);
}

int main(void)
{
	log_user_message("%s");
	return 0;
}
