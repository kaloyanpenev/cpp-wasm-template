#include <libExample/libExample.h>

#include <print>

int libExample::runApp(double num)
{
	std::print("Hello world from libExample. Number is {}", num);
	return 0;
}