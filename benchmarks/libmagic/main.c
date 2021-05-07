#include <stdio.h>
#include <unistd.h>
#include <magic.h>

int main(int argc, char *argv[])
{
	if (argc != 2)
	{
		printf("usage: main /path/to/magic/db\n");
		return 1;
	}

	char *filename = argv[1];

	if (access(filename, F_OK))
	{
		printf("%s does not exist\n", filename);
		return 1;
	}

	/*
	Creates a magic cookie pointer specifying that the other
	functions should either return a MIME type string or return
	a MIME encoding, instead of a textual description.
	*/
	magic_t magic_cookie = magic_open(MAGIC_MIME);

	if (magic_cookie == NULL)
	{
		printf("creation of magic cookie failed\n");
		return 1;
	}

	return 0;
}