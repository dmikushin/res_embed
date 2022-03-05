#include "res_embed.h"

#include <cstdio>

int main(int argc, char* argv[])
{
	printf("%s", res::embed::get("resource"));
	return 0;
}

