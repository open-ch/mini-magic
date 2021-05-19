#include <stdio.h>
#include <unistd.h>
#include <magic.h>
#include <time.h>
#include <stdlib.h>
#include <math.h>
#include <dirent.h>
#include <string.h>

#define MAX_PATH_LENGTH 300
#define SIZE_AVGS 60

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

int main(int argc, char *argv[])
{
	if (argc != 4)
	{
		printf("usage: bench /path/to/magic/db /path/to/test/files nbr_it\n");
		return 1;
	}
	printf("[...] checking args\n");
	const char *filename = argv[1];

	if (access(filename, F_OK))
	{
		printf("%s does not exist\n", filename);
		return 1;
	}

	const char *path_to_files = argv[2];
	if (access(path_to_files, F_OK))
	{
		printf("%s does not exist\n", path_to_files);
		return 1;
	}

	size_t nbr_iteration = (size_t)atoi(argv[3]);

	printf("[...] creating magic cookie\n");
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

	printf("[...] loading magic DB\n");
	// load the magic file/database
	if (magic_load(magic_cookie, filename) != 0)
	{
		printf("loading magic database failed: %s\n", magic_error(magic_cookie));
		magic_close(magic_cookie);
		return 1;
	}

	printf("[...] opening output file\n");
	FILE *fptr;
	fptr = fopen("output", "w");

	if (fptr == NULL)
	{
		printf("could not create output file\n");
		magic_close(magic_cookie);
		return 1;
	}

	fprintf(fptr, "|File|Mean[s]|Variance[s ^ 2]|STD[s]|\n");
	fprintf(fptr, "|---|---|---|---|\n");

	// loop though the test files
	DIR *files_dir;
	struct dirent *file;
	size_t count = 0;
	printf("[...] starting benchmarks\n");

	//alloc memory to keep track of the averages
	double *averages = malloc(SIZE_AVGS * sizeof(double));
	if (averages == NULL)
	{
		printf("could not allocate memory for averages\n");
		fclose(fptr);
		magic_close(magic_cookie);
		return 1;
	}

	if ((files_dir = opendir(path_to_files)))
	{
		while ((file = readdir(files_dir)))
		{
			count++;
			//skipping . and ..
			if (count > 2)
			{
				// Allocate memory for the measurement
				double *measures = malloc(nbr_iteration * sizeof(double));
				if (measures == NULL)
				{
					printf("could not allocate memory for the measurements\n");
					free(averages);
					fclose(fptr);
					magic_close(magic_cookie);
					closedir(files_dir);
					return 1;
				}

				char path_to_file[MAX_PATH_LENGTH];
				strncpy(path_to_file, path_to_files, MAX_PATH_LENGTH);
				strncat(path_to_file, "/", MAX_PATH_LENGTH);
				strncat(path_to_file, file->d_name, MAX_PATH_LENGTH);

				// Repeat the process of finding the MIME type and save the time differences
				const char *description;
				for (size_t i = 0; i < nbr_iteration; i++)
				{
					double start_time = (double)clock() / CLOCKS_PER_SEC;
					description = magic_file(magic_cookie, path_to_file);
					double end_time = (double)clock() / CLOCKS_PER_SEC;
					measures[i] = end_time - start_time;
				}
				double avg = mean(measures, nbr_iteration);
				averages[count - 3] = avg;

				double v = var(measures, nbr_iteration);
				double stdev = std(measures, nbr_iteration);
				printf("### %s ###\n", path_to_file);
				printf("MIME: %s\n", description);
				printf("MEAN: %e s.\n", avg);
				printf("VARIANCE: %e s^2.\n", v);
				printf("STD: %e s.\n\n", stdev);
				fprintf(fptr, "|%s|%e|%e|%e|\n", file->d_name, avg, v, stdev);

				free(measures);
			}
		}
		closedir(files_dir);
	}

	printf("AVERAGE OF MEANS: %e.\n", mean(averages, count - 2));
	printf("STD OF MEANS: %e.\n", std(averages, count - 2));

	fclose(fptr);
	magic_close(magic_cookie);
	free(averages);

	return 0;
}