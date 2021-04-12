# MiniMagicDB

This repository contains the code for the `MiniMagicDB` project. The goal of this project is to easily build a minimal magic database. This minimal database only contains the tests needed to identify a list of given MIME types. The rationale behind this project is to speed up the search performed by `libmagic` when the goal is to only identify the MIME type of the file (possibly only among a subset of all available MIME types).

## Prerequisites

All the code of this repository is written in `perl`.

## Scripts

### mini-magic

This is the main tool of the repository. Its main purpose is to take a list of MIME types and create a minimal magic database by removing all unnecessary tests. More detail with `mini-magic -h`


### benchmarks

#### Module benchmarks

`benchmarks/benchmark.pl` is a script that can be used to benchmark the different parts of the MimeType module. More detail with `perl benchmarks/benchmark.pl -h`

#### End-to-end benchmarks

`benchmarks/e2e/e2e_benchmark.pl` is a script that can be used to benchmark the whole process of compiling a minimal magic database, i.e., filtering the tests and then use the file command to get the compiled minimal magic database. The test scenarios are in `benchmarks/e2e/mime-lists`. More detail with `perl benchmarks/e2e/e2e_benchmark.pl -h`
