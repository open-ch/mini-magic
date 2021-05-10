#include <stdio.h>
#include <unistd.h>
#include <magic.h>

//Compile it with: gcc -g main.c -lmagic -o bench
//Compile it with -pg for profiler
int main(int argc, const char *argv[])
{
	if (argc != 2)
	{
		printf("usage: bench /path/to/magic/db\n");
		return 1;
	}

	const char *filename = argv[1];

	if (access(filename, F_OK))
	{
		printf("%s does not exist\n", filename);
		return 1;
	}

	/*
	Creates a magic cookie pointer specifying that the other
	functions should either return a MIME type string or return
	a MIME encoding, instead of a textual description.
	Returns all matches, not just the first.
	*/
	magic_t magic_cookie = magic_open(MAGIC_MIME | MAGIC_CONTINUE);

	if (magic_cookie == NULL)
	{
		printf("creation of magic cookie failed\n");
		return 1;
	}

	// load the magic file/database
	if (magic_load(magic_cookie, filename) != 0)
	{
		printf("loading magic database failed: %s\n", magic_error(magic_cookie));
		magic_close(magic_cookie);
		return 1;
	}

	// Benchmark getting MIME types
	const char *test_file = "test.pdf";
	const char *description = magic_file(magic_cookie, test_file);

	printf("%s\n", description);
	magic_close(magic_cookie);

	return 0;
}