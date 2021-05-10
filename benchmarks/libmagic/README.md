# Benchmarking libmagic with minimal magic files

To assess the performance improvement gained by using a minimal magic file, we created the benchmark
`main_with_bench.c`. This benchmark measures the time needed to find the MIME type of the file `test.pdf` with
a given compiled magic file.

## Usage

The program can be compiled with the following command:

```bash
gcc main_with_bench.c -lmagic -o bench
```

This assumes that you have `libmagic` installed on you computer.

Once the the program has been compiled, you can run it with the (mandatory) arguments specifying the path to the
compiled magic file and the number of iterations with the following command:

```bash
./bench <path to magic file> <number of iterations>
```

This gives you the mean, the variance and the standard deviation of the measurements. 

## Magic files

In `magic_files/` we provide 3 tests magic files:
- magic.mgc: the default compiled magic file for the version 5.39 of libmagic
- middle.mgc: compiled magic file obtained running the CLI tool with the option `-a` (and the magic files for the version 5.39 of libmagic). This magic file contains 1035 tests.
- small.mgc:  compiled magic file obtained running the CLI tool with the option `--mime-types "biosig/atf,text/x-nawk,application/x-sega-cd-rom,application/x-dbf,application/vnd.stardivision.math,image/heic,video/x-jng,image/x-os2-graphics,application/pdf,application/javascript,application/x-garmin-typ,biosig/ced-smr,application/x-iso9660-image"` (and the magic files for the version 5.39 of libmagic). This magic file contains 35 tests.

Feel free to test it with your own magic file.

## Results

We gathered the results of the benchmarks in th following table:


| Magic DB   |   Mean [s]   | Variance [s^2] | STD [s]      |
| ---------- | :----------: | -------------: | ------------ |
| magic.mgc  | 2.006678e-04 |   4.174057e-10 | 2.043051e-05 |
| middle.mgc | 1.831800e-04 |   5.081674e-10 | 2.254257e-05 |
| small.mgc  | 1.734893e-04 |   2.615102e-10 | 1.617128e-05 |

Those results were obtained with `1000000` iterations on a `13-inch 2017 MacBook Pro` with a `3.1 GHz Dual-Core Intel Core i5` and `16 Gb` of RAM.
