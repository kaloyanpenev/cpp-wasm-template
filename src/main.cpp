#include <iostream>

#include <libExample/libExample.h>

#include "exampleHeader.h"

int main()
{
	libExample::helloWorldCPP23();

	std::cout << "PI is: " << exampleHeader::PI << "\n";

	return 0;
}
