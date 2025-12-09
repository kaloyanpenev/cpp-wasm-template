#include <gtest/gtest.h>

int add(int lhs, int rhs)
{
	return lhs + rhs;
}

TEST(Addition, ComputesSumOfTwoInts)
{
	EXPECT_EQ(add(2, 3), 5);
	EXPECT_EQ(add(-2, 3), 1);
	EXPECT_EQ(add(0, 0), 0);
}
