# Benchmarking libmagic with minimal magic files

To assess the performance improvement gained by using a minimal magic file, we created the benchmark
`main.c`. This benchmark measures the time needed to find the MIME type of a file with
a given compiled magic file.

## Usage

The program can be compiled with the following command:

```bash
gcc main.c -lmagic -o bench
```

This assumes that you have `libmagic` installed on you computer.

Once the the program has been compiled, you can run it with the (mandatory) arguments specifying the path to the
compiled magic file, the path to the directory conatining the test files and the number of iterations with the following command:

```bash
./bench <path to magic file> <path to test files dir> <number of iterations>
```

This gives you the mean, the variance and the standard deviation of the measurements (per file). It also outputs a file containing those values in a markdown table format. 

## Magic files

In `magic_files/` we provide 3 tests magic files:
- magic.mgc: the default compiled magic file for the version 5.39 of libmagic
- middle.mgc: compiled magic file obtained running the CLI tool with the option `-a` (and the magic files for the version 5.39 of libmagic). This magic file contains 1035 tests.
- small.mgc:  compiled magic file obtained running the CLI tool with the option `--mime-types "biosig/atf,text/x-nawk,application/x-sega-cd-rom,application/x-dbf,application/vnd.stardivision.math,image/heic,video/x-jng,image/x-os2-graphics,application/pdf,application/javascript,application/x-garmin-typ,biosig/ced-smr,application/x-iso9660-image"` (and the magic files for the version 5.39 of libmagic). This magic file contains 35 tests.

Feel free to test it with your own magic file.

## Results

We gathered the results of the benchmarks in th following tables. Those results were obtained with `10000` iterations on a `13-inch 2017 MacBook Pro` with a `3.1 GHz Dual-Core Intel Core i5` and `16 Gb` of RAM.

### Comparison
#### All results in a nutshell

The averages of the benchmarks and the standard deviations for each magic file are:

| Magic file | Mean[s]      | STD[s]       |
| ---------- | ------------ | ------------ |
| magic.mgc  | 2.309776e-03 | 3.491043e-03 |
| middle.mgc | 9.792393e-04 | 1.582954e-03 |
| small.mgc  | 9.129508e-05 | 8.813377e-05 |

We can see that the overall mean of the benchmarks decrease by a factor 10 for each different magic file. This decrease is inversely proportional to the increase of the numbers of tests in each magic file. Moreover, we can see that the standard deviation is almost as big the mean.
This is due to the fact that the time to detect a MIME type is heavily impacted by the number of tests that must be performed for the detection. This ends in the presence of outliers that are way bigger or smaller than the average. 

#### All results

##### magic.mgc

| File                                                                           | Mean[s]      | Variance[s ^ 2] | STD[s]       |
| ------------------------------------------------------------------------------ | ------------ | --------------- | ------------ |
| text-x-powershell.ps1                                                          | 1.089250e-02 | 1.131575e-06    | 1.063755e-03 |
| image-png.png                                                                  | 6.174810e-05 | 2.720116e-10    | 1.649278e-05 |
| application-x-gnupg-keyring.gpg                                                | 2.933993e-04 | 6.106893e-09    | 7.814661e-05 |
| application-jar.jar                                                            | 2.186624e-04 | 3.558988e-09    | 5.965725e-05 |
| application-msword.doc                                                         | 5.042843e-04 | 1.335793e-08    | 1.155765e-04 |
| text-x-powershell.psd1                                                         | 8.805772e-03 | 4.623735e-07    | 6.799805e-04 |
| application-marc.md5sums                                                       | 5.851885e-03 | 2.992208e-07    | 5.470108e-04 |
| application-x-object.mod                                                       | 3.941673e-04 | 9.585136e-09    | 9.790371e-05 |
| text-x-powershell.psm1                                                         | 1.142924e-02 | 5.951763e-07    | 7.714767e-04 |
| application-cdfv2.db                                                           | 4.149927e-04 | 9.777354e-09    | 9.888050e-05 |
| application-vnd.iccprofile.pf                                                  | 4.038822e-04 | 7.762583e-09    | 8.810552e-05 |
| application-x-gdbm.db                                                          | 2.158368e-04 | 3.216914e-09    | 5.671785e-05 |
| msofficemacros.xlsm                                                            | 2.148046e-04 | 2.541797e-09    | 5.041624e-05 |
| application-winhelp.hlp                                                        | 5.844439e-04 | 1.174512e-08    | 1.083749e-04 |
| application-vnd.ms-msi.mst                                                     | 5.187552e-04 | 1.177588e-08    | 1.085167e-04 |
| application-x-xz.xz                                                            | 1.672374e-04 | 1.033165e-09    | 3.214289e-05 |
| application-vnd.ms-powerpoint.ppt                                              | 5.764336e-04 | 1.320526e-08    | 1.149141e-04 |
| application-vnd.openxmlformats-officedocument.spreadsheetml.sheet.xlsx         | 3.361759e-04 | 7.791140e-09    | 8.826744e-05 |
| application-x-dosexec.sys                                                      | 3.921399e-04 | 7.251111e-09    | 8.515345e-05 |
| text-x-makefile.ps                                                             | 1.081632e-02 | 1.277886e-06    | 1.130436e-03 |
| application-vnd.openxmlformats-officedocument.spreadsheetml.sheet.xlsm         | 3.438306e-04 | 1.017143e-08    | 1.008535e-04 |
| application-pgp-keys.key                                                       | 6.467572e-03 | 6.899646e-07    | 8.306411e-04 |
| text-plain.bat                                                                 | 6.226193e-03 | 1.226979e-07    | 3.502826e-04 |
| x-custom-mime-sylk.slk                                                         | 5.311660e-03 | 1.011091e-07    | 3.179766e-04 |
| application-zip.doc.zip                                                        | 1.685300e-04 | 1.153362e-09    | 3.396119e-05 |
| application-cdfv2-corrupt.vsmacros                                             | 5.195061e-04 | 6.872153e-09    | 8.289845e-05 |
| text-rtf.rtf                                                                   | 9.665222e-03 | 3.397417e-07    | 5.828736e-04 |
| application-x-ms-sdb.sdb                                                       | 1.481718e-04 | 8.204153e-10    | 2.864289e-05 |
| image-tiff.tiff                                                                | 6.040520e-05 | 1.642678e-10    | 1.281670e-05 |
| application-x-bittorrent.torrent                                               | 9.126240e-05 | 2.685761e-10    | 1.638829e-05 |
| inode-x-empty.md                                                               | 4.303500e-06 | 1.931188e-12    | 1.389672e-06 |
| application-vnd.ms-fontobject.h                                                | 1.006224e-03 | 1.433113e-08    | 1.197127e-04 |
| text-x-msdos-batch.bat                                                         | 3.455695e-03 | 4.317411e-08    | 2.077838e-04 |
| application-xml.conf                                                           | 5.425884e-04 | 6.286972e-09    | 7.929043e-05 |
| application-x-sharedlib.so                                                     | 3.385926e-04 | 3.874402e-09    | 6.224470e-05 |
| application-x-elc.elc                                                          | 2.185308e-04 | 1.285951e-09    | 3.586015e-05 |
| application-postscript.ps                                                      | 7.281588e-03 | 3.691732e-07    | 6.075963e-04 |
| application-vnd.oasis.opendocument.text.odt                                    | 1.937999e-04 | 1.228813e-09    | 3.505444e-05 |
| application-x-empty                                                            | 4.343400e-06 | 2.629876e-12    | 1.621689e-06 |
| application-vnd.openxmlformats-officedocument.presentationml.presentation.pptx | 2.559903e-04 | 2.195963e-09    | 4.686110e-05 |
| application-pgp-signature.gpg                                                  | 5.292505e-03 | 1.760771e-07    | 4.196154e-04 |
| application-x-compress.z                                                       | 1.710736e-04 | 5.376082e-10    | 2.318638e-05 |
| application-x-tar.tar                                                          | 3.426306e-04 | 2.145986e-09    | 4.632479e-05 |
| application-x-java-applet.class                                                | 1.309201e-04 | 3.966571e-10    | 1.991625e-05 |
| application-zip.nupkg                                                          | 2.076468e-04 | 8.213336e-10    | 2.865892e-05 |
| text-plain.js                                                                  | 1.131745e-02 | 7.945541e-07    | 8.913777e-04 |
| application-zip.zip                                                            | 3.359681e-04 | 3.016861e-09    | 5.492596e-05 |
| application-text-plain.cmd                                                     | 5.559650e-03 | 1.414978e-07    | 3.761620e-04 |
| text-x-shellscript                                                             | 1.306989e-03 | 1.207049e-08    | 1.098658e-04 |
| application-x-sqlite3.sqlite                                                   | 1.576524e-04 | 2.902432e-10    | 1.703652e-05 |
| application-pdf.pdf                                                            | 1.722385e-04 | 3.459120e-10    | 1.859871e-05 |
| application-x-bzip2.bz2                                                        | 2.279260e-04 | 7.938521e-10    | 2.817538e-05 |
| application-vnd.ms-opentype.otf                                                | 2.086206e-04 | 6.826883e-10    | 2.612830e-05 |
| x-custom-mime-windows-shortcut.lnk                                             | 2.778764e-04 | 1.254659e-09    | 3.542117e-05 |
| application-zip.war                                                            | 1.560708e-04 | 4.013122e-10    | 2.003278e-05 |
| text-plain.url                                                                 | 5.717850e-03 | 1.819835e-07    | 4.265952e-04 |
| application-x-java-keystore                                                    | 2.971130e-04 | 2.485918e-09    | 4.985898e-05 |
| text-plain.vbs                                                                 | 6.690128e-03 | 2.248400e-07    | 4.741730e-04 |

##### middle.mgc

| File                                                                           | Mean[s]      | Variance[s ^ 2] | STD[s]       |
| ------------------------------------------------------------------------------ | ------------ | --------------- | ------------ |
| text-x-powershell.ps1                                                          | 4.786858e-03 | 3.567469e-07    | 5.972829e-04 |
| image-png.png                                                                  | 5.499680e-05 | 2.999762e-10    | 1.731982e-05 |
| application-x-gnupg-keyring.gpg                                                | 1.349156e-04 | 1.962130e-09    | 4.429593e-05 |
| application-jar.jar                                                            | 1.437430e-04 | 1.977135e-09    | 4.446499e-05 |
| application-msword.doc                                                         | 3.020115e-04 | 7.600949e-09    | 8.718342e-05 |
| text-x-powershell.psd1                                                         | 3.673278e-03 | 2.734935e-07    | 5.229660e-04 |
| application-marc.md5sums                                                       | 1.435346e-03 | 6.199420e-08    | 2.489863e-04 |
| application-x-object.mod                                                       | 2.004215e-04 | 2.492903e-09    | 4.992898e-05 |
| text-x-powershell.psm1                                                         | 6.047317e-03 | 3.849871e-07    | 6.204733e-04 |
| application-cdfv2.db                                                           | 1.937336e-04 | 2.418486e-09    | 4.917811e-05 |
| application-vnd.iccprofile.pf                                                  | 2.220523e-04 | 2.975092e-09    | 5.454440e-05 |
| application-x-gdbm.db                                                          | 1.112374e-04 | 7.249692e-10    | 2.692525e-05 |
| msofficemacros.xlsm                                                            | 1.506601e-04 | 2.194185e-09    | 4.684212e-05 |
| application-winhelp.hlp                                                        | 4.031469e-04 | 1.001235e-08    | 1.000617e-04 |
| application-vnd.ms-msi.mst                                                     | 3.082632e-04 | 6.807238e-09    | 8.250599e-05 |
| application-x-xz.xz                                                            | 1.609114e-04 | 1.267212e-09    | 3.559792e-05 |
| application-vnd.ms-powerpoint.ppt                                              | 3.433694e-04 | 6.037956e-09    | 7.770429e-05 |
| application-vnd.openxmlformats-officedocument.spreadsheetml.sheet.xlsx         | 2.276794e-04 | 2.633254e-09    | 5.131525e-05 |
| application-x-dosexec.sys                                                      | 2.223648e-04 | 3.576940e-09    | 5.980752e-05 |
| text-x-makefile.ps                                                             | 5.599819e-03 | 3.498988e-07    | 5.915225e-04 |
| application-vnd.openxmlformats-officedocument.spreadsheetml.sheet.xlsm         | 2.143149e-04 | 2.338046e-09    | 4.835334e-05 |
| application-pgp-keys.key                                                       | 1.834773e-03 | 7.339425e-08    | 2.709137e-04 |
| text-plain.bat                                                                 | 1.868149e-03 | 6.368202e-08    | 2.523530e-04 |
| x-custom-mime-sylk.slk                                                         | 1.212252e-03 | 3.382511e-08    | 1.839161e-04 |
| application-zip.doc.zip                                                        | 9.908300e-05 | 6.582103e-10    | 2.565561e-05 |
| application-cdfv2-corrupt.vsmacros                                             | 3.190122e-04 | 5.754674e-09    | 7.585957e-05 |
| text-rtf.rtf                                                                   | 4.504667e-03 | 3.103557e-07    | 5.570958e-04 |
| application-x-ms-sdb.sdb                                                       | 8.914020e-05 | 8.676981e-10    | 2.945672e-05 |
| image-tiff.tiff                                                                | 4.755850e-05 | 2.565170e-10    | 1.601615e-05 |
| application-x-bittorrent.torrent                                               | 7.988320e-05 | 4.162452e-10    | 2.040209e-05 |
| inode-x-empty.md                                                               | 4.511000e-06 | 3.514479e-12    | 1.874694e-06 |
| application-vnd.ms-fontobject.h                                                | 8.835417e-04 | 3.611554e-08    | 1.900409e-04 |
| text-x-msdos-batch.bat                                                         | 4.385950e-04 | 1.329678e-08    | 1.153117e-04 |
| application-xml.conf                                                           | 4.783362e-04 | 1.709089e-08    | 1.307321e-04 |
| application-x-sharedlib.so                                                     | 2.000344e-04 | 3.799730e-09    | 6.164195e-05 |
| application-x-elc.elc                                                          | 1.877173e-04 | 2.786529e-09    | 5.278759e-05 |
| application-postscript.ps                                                      | 3.251006e-03 | 3.604670e-07    | 6.003890e-04 |
| application-vnd.oasis.opendocument.text.odt                                    | 1.337927e-04 | 1.282514e-09    | 3.581220e-05 |
| application-x-empty                                                            | 4.586100e-06 | 4.791987e-12    | 2.189061e-06 |
| application-vnd.openxmlformats-officedocument.presentationml.presentation.pptx | 1.977452e-04 | 2.697088e-09    | 5.193349e-05 |
| application-pgp-signature.gpg                                                  | 1.279282e-03 | 5.283783e-08    | 2.298648e-04 |
| application-x-compress.z                                                       | 8.131660e-05 | 5.752440e-10    | 2.398424e-05 |
| application-x-tar.tar                                                          | 2.061831e-04 | 2.749900e-09    | 5.243949e-05 |
| application-x-java-applet.class                                                | 6.896390e-05 | 4.401900e-10    | 2.098071e-05 |
| application-zip.nupkg                                                          | 1.716195e-04 | 2.909130e-09    | 5.393635e-05 |
| text-plain.js                                                                  | 6.300396e-03 | 5.436904e-07    | 7.373536e-04 |
| application-zip.zip                                                            | 2.841155e-04 | 4.523684e-09    | 6.725834e-05 |
| application-text-plain.cmd                                                     | 1.396300e-03 | 5.586241e-08    | 2.363523e-04 |
| text-x-shellscript                                                             | 1.302754e-03 | 4.402506e-08    | 2.098215e-04 |
| application-x-sqlite3.sqlite                                                   | 1.675490e-04 | 1.986965e-09    | 4.457539e-05 |
| application-pdf.pdf                                                            | 1.751580e-04 | 1.653758e-09    | 4.066643e-05 |
| application-x-bzip2.bz2                                                        | 1.079687e-04 | 9.984245e-10    | 3.159786e-05 |
| application-vnd.ms-opentype.otf                                                | 1.302296e-04 | 1.249654e-09    | 3.535044e-05 |
| x-custom-mime-windows-shortcut.lnk                                             | 1.377611e-04 | 1.528186e-09    | 3.909202e-05 |
| application-zip.war                                                            | 9.908010e-05 | 8.287499e-10    | 2.878802e-05 |
| text-plain.url                                                                 | 1.703907e-03 | 8.496058e-08    | 2.914800e-04 |
| application-x-java-keystore                                                    | 2.088012e-04 | 2.722549e-09    | 5.217805e-05 |
| text-plain.vbs                                                                 | 2.203672e-03 | 1.237060e-07    | 3.517186e-04 |

##### small.mgc

| File                                                                           | Mean[s]      | Variance[s ^ 2] | STD[s]       |
| ------------------------------------------------------------------------------ | ------------ | --------------- | ------------ |
| text-x-powershell.ps1                                                          | 1.339993e-04 | 7.933819e-10    | 2.816704e-05 |
| image-png.png                                                                  | 4.939960e-05 | 1.559249e-10    | 1.248699e-05 |
| application-x-gnupg-keyring.gpg                                                | 3.730350e-05 | 9.095519e-11    | 9.537043e-06 |
| application-jar.jar                                                            | 7.217760e-05 | 2.338511e-10    | 1.529219e-05 |
| application-msword.doc                                                         | 1.290182e-04 | 1.419756e-09    | 3.767965e-05 |
| text-x-powershell.psd1                                                         | 7.389940e-05 | 2.119029e-10    | 1.455688e-05 |
| application-marc.md5sums                                                       | 3.621690e-05 | 7.968325e-11    | 8.926548e-06 |
| application-x-object.mod                                                       | 6.136870e-05 | 1.959164e-10    | 1.399701e-05 |
| text-x-powershell.psm1                                                         | 2.801087e-04 | 1.807109e-09    | 4.251011e-05 |
| application-cdfv2.db                                                           | 5.538250e-05 | 1.566020e-10    | 1.251407e-05 |
| application-vnd.iccprofile.pf                                                  | 3.534920e-05 | 8.873646e-11    | 9.420003e-06 |
| application-x-gdbm.db                                                          | 7.540810e-05 | 2.461996e-10    | 1.569075e-05 |
| msofficemacros.xlsm                                                            | 6.801990e-05 | 2.289465e-10    | 1.513098e-05 |
| application-winhelp.hlp                                                        | 9.246340e-05 | 4.848781e-10    | 2.201995e-05 |
| application-vnd.ms-msi.mst                                                     | 1.401245e-04 | 1.434762e-09    | 3.787826e-05 |
| application-x-xz.xz                                                            | 1.481133e-04 | 7.379749e-10    | 2.716569e-05 |
| application-vnd.ms-powerpoint.ppt                                              | 1.753401e-04 | 1.117217e-09    | 3.342480e-05 |
| application-vnd.openxmlformats-officedocument.spreadsheetml.sheet.xlsx         | 1.513600e-04 | 7.447104e-10    | 2.728938e-05 |
| application-x-dosexec.sys                                                      | 1.489187e-04 | 7.510467e-10    | 2.740523e-05 |
| text-x-makefile.ps                                                             | 8.769850e-05 | 2.459218e-10    | 1.568189e-05 |
| application-vnd.openxmlformats-officedocument.spreadsheetml.sheet.xlsm         | 1.382585e-04 | 5.243679e-10    | 2.289908e-05 |
| application-pgp-keys.key                                                       | 4.897340e-05 | 1.246757e-10    | 1.116583e-05 |
| text-plain.bat                                                                 | 4.218100e-05 | 7.961204e-11    | 8.922558e-06 |
| x-custom-mime-sylk.slk                                                         | 3.687800e-05 | 8.729252e-11    | 9.343046e-06 |
| application-zip.doc.zip                                                        | 4.796140e-05 | 2.626829e-10    | 1.620750e-05 |
| application-cdfv2-corrupt.vsmacros                                             | 1.617064e-04 | 1.000662e-09    | 3.163324e-05 |
| text-rtf.rtf                                                                   | 6.119278e-04 | 5.621719e-09    | 7.497813e-05 |
| application-x-ms-sdb.sdb                                                       | 3.606700e-05 | 6.222791e-11    | 7.888467e-06 |
| image-tiff.tiff                                                                | 3.562000e-05 | 7.464580e-11    | 8.639780e-06 |
| application-x-bittorrent.torrent                                               | 7.352590e-05 | 4.162279e-10    | 2.040166e-05 |
| inode-x-empty.md                                                               | 4.935600e-06 | 4.719253e-12    | 2.172384e-06 |
| application-vnd.ms-fontobject.h                                                | 4.048070e-05 | 1.792178e-10    | 1.338723e-05 |
| text-x-msdos-batch.bat                                                         | 4.147150e-05 | 2.210198e-10    | 1.486673e-05 |
| application-xml.conf                                                           | 4.480890e-05 | 1.665414e-10    | 1.290509e-05 |
| application-x-sharedlib.so                                                     | 4.707630e-05 | 1.819223e-10    | 1.348786e-05 |
| application-x-elc.elc                                                          | 1.015621e-04 | 3.638441e-10    | 1.907470e-05 |
| application-postscript.ps                                                      | 6.038780e-05 | 3.525424e-10    | 1.877611e-05 |
| application-vnd.oasis.opendocument.text.odt                                    | 6.643820e-05 | 2.620762e-10    | 1.618877e-05 |
| application-x-empty                                                            | 4.377300e-06 | 3.595545e-12    | 1.896192e-06 |
| application-vnd.openxmlformats-officedocument.presentationml.presentation.pptx | 1.150559e-04 | 7.428592e-10    | 2.725544e-05 |
| application-pgp-signature.gpg                                                  | 3.983600e-05 | 1.708887e-10    | 1.307244e-05 |
| application-x-compress.z                                                       | 3.380310e-05 | 7.355853e-11    | 8.576627e-06 |
| application-x-tar.tar                                                          | 5.860230e-05 | 1.534353e-10    | 1.238690e-05 |
| application-x-java-applet.class                                                | 4.114040e-05 | 8.710289e-11    | 9.332893e-06 |
| application-zip.nupkg                                                          | 7.452520e-05 | 2.521148e-10    | 1.587812e-05 |
| text-plain.js                                                                  | 2.212077e-04 | 2.042934e-09    | 4.519883e-05 |
| application-zip.zip                                                            | 1.489928e-04 | 8.442031e-10    | 2.905517e-05 |
| application-text-plain.cmd                                                     | 3.841820e-05 | 8.538531e-11    | 9.240417e-06 |
| text-x-shellscript                                                             | 9.061370e-05 | 3.595363e-10    | 1.896144e-05 |
| application-x-sqlite3.sqlite                                                   | 1.522086e-04 | 9.856389e-10    | 3.139489e-05 |
| application-pdf.pdf                                                            | 1.541607e-04 | 6.825197e-10    | 2.612508e-05 |
| application-x-bzip2.bz2                                                        | 3.514880e-05 | 7.961406e-11    | 8.922671e-06 |
| application-vnd.ms-opentype.otf                                                | 8.399680e-05 | 2.643676e-10    | 1.625938e-05 |
| x-custom-mime-windows-shortcut.lnk                                             | 3.626890e-05 | 7.242039e-11    | 8.510017e-06 |
| application-zip.war                                                            | 3.716670e-05 | 8.676211e-11    | 9.314618e-06 |
| text-plain.url                                                                 | 3.823090e-05 | 1.168284e-10    | 1.080872e-05 |
| application-x-java-keystore                                                    | 1.484475e-04 | 6.700174e-10    | 2.588470e-05 |
| text-plain.vbs                                                                 | 5.098270e-05 | 1.175150e-10    | 1.084043e-05 |
