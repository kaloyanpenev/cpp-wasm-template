#include <gtest/gtest.h>

#include <libExample/libExample.h>

TEST(LibExampleTests, RunApp)
{
	ASSERT_EQ(libExample::runApp(3.14), 0);
}
