# mini-magic

[![License](https://img.shields.io/badge/License-Apache%202.0-blue.svg)](LICENSE)

> Remove unnecessary tests from a magic database to speed up MIME type detection
> with libmagic

## Background

Sometimes, you might want to know exactly what the type of a file is. This might be
particularly relevant in a security context where you cannot rely solely on file 
extensions. One way to do that is to use 
[libmagic](https://man7.org/linux/man-pages/man3/libmagic.3.html) (and its command
[file](https://man7.org/linux/man-pages/man1/file.1.html)) and try to detect
the [MIME type](https://en.wikipedia.org/wiki/Media_type) of the file. To achieve
this task, libmagic relies on [magic files](https://man7.org/linux/man-pages/man4/magic.4.html),
often called `magic.mgc` on linux distributions, containing heuristic tests.

Going through the tests to determine the MIME type of one file is already a long
and resource intensive process. Now imagine, you want to block some file types, on the fly,
before they can harm the devices on your network. This requires repeating this process
hundreds or even thousands of times in short lapses of time. That is the reason we
started this project. **We wanted to speed up the search performed by libmagic
when the goal is to identify only a subset of MIME types.** To achieve our goal,
we take the [official magic files](https://github.com/file/file/tree/master/magic/Magdir)
and remove all the unnecessary tests for the detection of the MIME types we are interested in.

## Usage

See the [Install](#install) section for more details on the requirements of our tools. 

### CLI

With our [CLI tool](bin), you can quickly create a minimal magic file called `mini_magic` containing 
only the necessary tests to detect `application/pdf` and `application/x-executable` from the magic
files located at `Magdir`:

```bash
mini-magic --mime-types application/pdf,application/x-executable --src Magdir --magic-filename mini_magic
```
The minimal magic file, `mini_magic`, can either be used as is by `libmagic`:

```bash
# -i causes the file command to output mime type strings
file -m mini_magic some_file -i
```

or it can be first compiled to further improve the performance:

```bash
file -C -m mini_magic
```

This produces the compiled magic database `mini_magic.mgc` .

For more details on the CLI capabilities and options use the flag `--help`.

### Perl module

We also provide a [perl module](lib) called `MiniMagic`. You can achieve the same
result as the CLI tool with the following code snippet:

```perl

# list of MIME types you want to detect
my $mime_types = ["application/pdf", "application/x-executable"];

# path to the directory containing the magic files
my $src_dir = "Magdir";

# name of the mini magic file containing only the necessary tests
my $magic_name = "mini_magic";

create_mini_magic_file($mime_types, $src_dir, $magic_name);
```

See the [API](#api) section for more details about the module.

### Docker

Finally, for those who do not want to deal with the dependencies, we dockerized the project.
To build the image you can simply run the following command from the root of the project:

```
# mini-magic is the name of the new docker image
docker build -t mini-magic . 
```

Once the build is done, you can run the following command to create the same magic file as in the previous examples:

```
docker run -v "$(pwd):/data" mini-magic --mime-types application/pdf,application/x-executable --magic-filename /data/mini_magic
```


## API

```perl
use MiniMagic qw/create_mini_magic_file download_magic_files list_mime_types print_list_mime_types/;
```

### create_mini_magic_file($mime_types, $src_dir, $magic_name)

`create_mini_magic_file` creates a magic file called `$magic_name` containing
all tests needed to detect the MIME types listed in the (referenced) array
`$mime_types`. For this, it uses the definition located at `$src_dir`.

### download_magic_files($src_dir, $version)

`download_magic_files` downloads all the magic files compatible with
libmagic version `$version` from the [official repository]("http://ftp.astron.com/pub/file/") 
and save them to the directory `$src_dir`.

### list_mime_types($src_dir)

`list_mime_types` creates a (referenced) array containing all MIME types covered
by the magic files in the directory `$src_dir`.

### print_list_mime_types($src_dir)

`print_list_mime_types` prints all MIME types covered by the magic files in 
the directory `$src_dir`.

### benchmarks and tests

- [Tests](./tests) - unit and e2e tests
- [Benchmark](./benchmarks) - module and e2e benchmarks

All tests and benchmarks can be run as follow:

```bash
perl name_script.pl
```

## Install

The module `MiniMagic` (and the CLI tool `mini-magic`) requires `perl 5.28` 
to function properly. In addition to that, you might need to 
[install](https://www.cpan.org/modules/INSTALL.html) the following additional
modules:

- Log::Any
- Log::Any::Adapter::Dispatch
- Log::Log4perl
- Log::Any::Adapter::Log4perl
- Const::Fast
- IPC::Run
- LWP::Simple
- Archive::Extract
- File::Slurper
- File::Copy::Recursive

## License

[Apache License 2.0](LICENSE)
