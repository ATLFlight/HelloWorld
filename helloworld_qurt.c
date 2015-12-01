#include "qurt_log.h"
#include "helloworld.h"

uint32 helloworld_say_hello()
{
	LOG_MSG("Hello World");
	return 0;
}
