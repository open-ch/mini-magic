#include <stdio.h>
#include <unistd.h>
#include <magic.h>
#include <time.h>
#include <stdlib.h>
#include <math.h>

double mean(double *measures, size_t length)
{
	double sum = 0;

	for (size_t i = 0; i < length; i++)
	{
		sum += measures[i];
	}

	return sum / length;
}

double var(double *measures, size_t length)
{
	double avg = mean(measures, length);
	double sum_var = 0;

	for (size_t i = 0; i < length; i++)
	{
		sum_var += (measures[i] - avg) * (measures[i] - avg);
	}

	return sum_var / length;
}

double std(double *measures, size_t length)
{
	return sqrt(var(measures, length));
}

int main(int argc, const char *argv[])
{
	if (argc != 3)
	{
		printf("usage: bench /path/to/magic/db nbr_it\n");
		return 1;
	}

	const char *filename = argv[1];

	size_t nbr_iteration = (size_t)atoi(argv[2]);

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
	double *measures = calloc(nbr_iteration, sizeof(double));

	if (measures == NULL)
	{
		printf("could not allocate memory for the measurements\n");
		return 1;
	}

	for (size_t i = 0; i < nbr_iteration; i++)
	{
		double start_time = (double)clock() / CLOCKS_PER_SEC;
		const char *description = magic_file(magic_cookie, test_file);
		double end_time = (double)clock() / CLOCKS_PER_SEC;
		measures[i] = end_time - start_time;
	}
	printf("MEAN: %e s.\n", mean(measures, nbr_iteration));
	printf("VARIANCE: %e s^2.\n", var(measures, nbr_iteration));
	printf("STD: %e s.\n", std(measures, nbr_iteration));

	magic_close(magic_cookie);
	free(measures);
	return 0;
}