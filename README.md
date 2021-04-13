# mini-magic

This repository contains the code for the `mini-magic` project. The goal of this
project is to easily build a minimal magic database. This minimal database only
contains the tests needed to identify a list of given MIME types. The rationale
behind this project is to speed up the search performed by `libmagic` when the
goal is to only identify a subset of MIME types. 

## Required modules

This project is mainly written in `perl 5.28` and requires some additional modules.

### Log::Any

[Log::Any](https://metacpan.org/pod/Log::Any) provides a standard log production
API for modules. The modules `Log::Any::Adapter::Dispatch`, `Log::Log4perl`
and `Log::Any::Adapter::Log4perl` are also required.

### Const::Fast

[Const::Fast](https://metacpan.org/pod/distribution/Const-Fast/lib/Const/Fast.pm)
facilitates the creation of read-only scalars, arrays, and hashes.

### IPC::Run

[IPC::Run](https://metacpan.org/pod/IPC::Run) allows you to run and interact 
with child processes using files, pipes, and pseudo-ttys.

### LWP::Simple

[LWP::Simple](https://metacpan.org/pod/LWP::Simple) provides a simplified view 
of the libwww-perl library.

## Scripts

### mini-magic

This is the main tool of the repository. Its main purpose is to take a list of 
MIME types and create a magic file containing the least tests possible to detect
all MIME types listed. With this script you can also download the MIME type definitions
from the [official repository](http://ftp.astron.com/pub/file/) and list all
MIME types available to create the minimal magic file. More detail with `mini-magic -h`

### Tests

The tests are located in `mini-magic/tests`. You can find the unit tests in
`mini-magic/tests/t` and the end-to-end tests in `mini-magic/tests/e2e`. 

### Benchmarks

#### Module benchmarks

`benchmarks/benchmark.pl` is a script that can be used to benchmark the different parts of the MimeType module. More detail with `perl benchmarks/benchmark.pl -h`

#### End-to-end benchmarks

`benchmarks/e2e/e2e_benchmark.pl` is a script that can be used to benchmark the whole process of compiling a minimal magic database, i.e., filtering the tests and then use the file command to get the compiled minimal magic database. The test scenarios are in `benchmarks/e2e/mime-lists`. More detail with `perl benchmarks/e2e/e2e_benchmark.pl -h`
