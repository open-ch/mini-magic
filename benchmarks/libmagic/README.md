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

We gathered the results of the benchmarks in th following tables. Those results were obtained with `5000` iterations on a `13-inch 2017 MacBook Pro` with a `3.1 GHz Dual-Core Intel Core i5` and `16 Gb` of RAM.

### Comparison

We focus here on the file `application-pdf.pdf` as it is detected by all compiled magic files. The results are similar in this scenario for the other files. There average time of the benchmarks for each magic file is:

| magic.mgc    | middle.mgc   | small.mgc    |
| ------------ | ------------ | ------------ |
| 1.695864e-04 | 1.521896e-04 | 1.457780e-04 |

We can see that the average gets smaller and smaller. The smallest minimal magic file is **14.45%** faster than the default one.

### magic.mgc

| File                                                                           | Mean[s]      | Variance[s ^ 2] | STD[s]       |
| ------------------------------------------------------------------------------ | ------------ | --------------- | ------------ |
| text-x-powershell.ps1                                                          | 9.748099e-03 | 9.284833e-08    | 3.047102e-04 |
| image-png.png                                                                  | 5.608060e-05 | 4.497850e-11    | 6.706601e-06 |
| application-x-gnupg-keyring.gpg                                                | 2.548990e-04 | 5.963696e-10    | 2.442068e-05 |
| application-jar.jar                                                            | 1.874458e-04 | 3.712331e-10    | 1.926741e-05 |
| application-msword.doc                                                         | 4.326248e-04 | 2.023336e-09    | 4.498151e-05 |
| text-x-powershell.psd1                                                         | 8.413189e-03 | 4.196113e-07    | 6.477741e-04 |
| application-marc.md5sums                                                       | 5.567994e-03 | 4.644815e-08    | 2.155183e-04 |
| application-x-object.mod                                                       | 3.339230e-04 | 5.922267e-10    | 2.433571e-05 |
| text-x-powershell.psm1                                                         | 1.075739e-02 | 3.256107e-07    | 5.706231e-04 |
| application-cdfv2.db                                                           | 3.533394e-04 | 6.694894e-10    | 2.587449e-05 |
| application-vnd.iccprofile.pf                                                  | 3.529886e-04 | 8.185037e-10    | 2.860950e-05 |
| application-x-gdbm.db                                                          | 1.866516e-04 | 1.870386e-10    | 1.367621e-05 |
| msofficemacros.xlsm                                                            | 1.910968e-04 | 1.632330e-10    | 1.277627e-05 |
| application-winhelp.hlp                                                        | 5.050446e-04 | 9.402434e-10    | 3.066339e-05 |
| application-vnd.ms-msi.mst                                                     | 4.456592e-04 | 6.945183e-10    | 2.635371e-05 |
| application-x-xz.xz                                                            | 1.543516e-04 | 3.316160e-10    | 1.821033e-05 |
| application-vnd.ms-powerpoint.ppt                                              | 5.368428e-04 | 1.215397e-08    | 1.102451e-04 |
| application-vnd.openxmlformats-officedocument.spreadsheetml.sheet.xlsx         | 2.903876e-04 | 2.686181e-09    | 5.182838e-05 |
| application-x-dosexec.sys                                                      | 3.485224e-04 | 1.182713e-09    | 3.439059e-05 |
| text-x-makefile.ps                                                             | 1.072633e-02 | 1.168914e-06    | 1.081163e-03 |
| application-vnd.openxmlformats-officedocument.spreadsheetml.sheet.xlsm         | 2.702954e-04 | 1.290951e-09    | 3.592981e-05 |
| application-pgp-keys.key                                                       | 6.028550e-03 | 4.218813e-08    | 2.053975e-04 |
| text-plain.bat                                                                 | 6.081032e-03 | 4.537243e-08    | 2.130081e-04 |
| x-custom-mime-sylk.slk                                                         | 5.295017e-03 | 7.972128e-08    | 2.823496e-04 |
| application-zip.doc.zip                                                        | 1.576792e-04 | 2.973743e-10    | 1.724454e-05 |
| application-cdfv2-corrupt.vsmacros                                             | 4.820150e-04 | 3.447745e-09    | 5.871750e-05 |
| text-rtf.rtf                                                                   | 9.424732e-03 | 7.978852e-08    | 2.824686e-04 |
| application-x-ms-sdb.sdb                                                       | 1.399584e-04 | 2.431983e-10    | 1.559482e-05 |
| image-tiff.tiff                                                                | 5.712820e-05 | 3.791536e-11    | 6.157545e-06 |
| application-x-bittorrent.torrent                                               | 8.749380e-05 | 1.031360e-10    | 1.015559e-05 |
| inode-x-empty.md                                                               | 4.167000e-06 | 1.305511e-12    | 1.142590e-06 |
| application-vnd.ms-fontobject.h                                                | 9.413104e-04 | 5.881584e-09    | 7.669149e-05 |
| text-x-msdos-batch.bat                                                         | 3.428726e-03 | 2.121408e-08    | 1.456505e-04 |
| application-xml.conf                                                           | 5.067080e-04 | 1.439013e-09    | 3.793432e-05 |
| application-x-sharedlib.so                                                     | 3.119130e-04 | 8.807986e-10    | 2.967825e-05 |
| application-x-elc.elc                                                          | 2.065886e-04 | 3.040446e-10    | 1.743687e-05 |
| application-postscript.ps                                                      | 7.021405e-03 | 1.287184e-07    | 3.587735e-04 |
| application-vnd.oasis.opendocument.text.odt                                    | 1.821526e-04 | 3.475637e-10    | 1.864306e-05 |
| application-x-empty                                                            | 4.115600e-06 | 1.119037e-12    | 1.057845e-06 |
| application-vnd.openxmlformats-officedocument.presentationml.presentation.pptx | 2.378604e-04 | 5.326153e-10    | 2.307846e-05 |
| application-pgp-signature.gpg                                                  | 5.199636e-03 | 3.614144e-08    | 1.901090e-04 |
| application-x-compress.z                                                       | 1.682768e-04 | 3.304942e-10    | 1.817950e-05 |
| application-x-tar.tar                                                          | 3.350478e-04 | 1.328546e-09    | 3.644922e-05 |
| application-x-java-applet.class                                                | 1.271582e-04 | 1.957768e-10    | 1.399203e-05 |
| application-zip.nupkg                                                          | 2.039408e-04 | 5.802677e-10    | 2.408875e-05 |
| text-plain.js                                                                  | 1.110788e-02 | 1.422364e-07    | 3.771424e-04 |
| application-zip.zip                                                            | 3.139366e-04 | 9.353126e-10    | 3.058288e-05 |
| application-text-plain.cmd                                                     | 5.615867e-03 | 5.777020e-08    | 2.403543e-04 |
| text-x-shellscript                                                             | 1.278665e-03 | 4.501221e-09    | 6.709114e-05 |
| application-x-sqlite3.sqlite                                                   | 1.556350e-04 | 2.021566e-10    | 1.421818e-05 |
| application-pdf.pdf                                                            | 1.695864e-04 | 1.818469e-10    | 1.348506e-05 |
| application-x-bzip2.bz2                                                        | 2.228506e-04 | 4.667543e-10    | 2.160450e-05 |
| application-vnd.ms-opentype.otf                                                | 2.041048e-04 | 3.777126e-10    | 1.943483e-05 |
| x-custom-mime-windows-shortcut.lnk                                             | 2.711046e-04 | 7.479501e-10    | 2.734868e-05 |
| application-zip.war                                                            | 1.541682e-04 | 2.573203e-10    | 1.604121e-05 |
| text-plain.url                                                                 | 5.807687e-03 | 4.520192e-08    | 2.126074e-04 |
| application-x-java-keystore                                                    | 2.829710e-04 | 7.331398e-10    | 2.707655e-05 |
| text-plain.vbs                                                                 | 6.532632e-03 | 4.291302e-08    | 2.071546e-04 |

## middle.mgc

| File                                                                           | Mean[s]      | Variance[s ^ 2] | STD[s]       |
| ------------------------------------------------------------------------------ | ------------ | --------------- | ------------ |
| text-x-powershell.ps1                                                          | 4.217073e-03 | 3.406956e-08    | 1.845794e-04 |
| image-png.png                                                                  | 4.709940e-05 | 2.441152e-11    | 4.940802e-06 |
| application-x-gnupg-keyring.gpg                                                | 1.069424e-04 | 1.508327e-10    | 1.228140e-05 |
| application-jar.jar                                                            | 1.171466e-04 | 1.839823e-10    | 1.356401e-05 |
| application-msword.doc                                                         | 2.402384e-04 | 6.102668e-10    | 2.470358e-05 |
| text-x-powershell.psd1                                                         | 3.197275e-03 | 1.929442e-08    | 1.389044e-04 |
| application-marc.md5sums                                                       | 1.224972e-03 | 4.595030e-09    | 6.778665e-05 |
| application-x-object.mod                                                       | 1.769626e-04 | 3.946328e-10    | 1.986537e-05 |
| text-x-powershell.psm1                                                         | 5.427241e-03 | 3.472956e-08    | 1.863587e-04 |
| application-cdfv2.db                                                           | 1.684970e-04 | 2.026708e-10    | 1.423625e-05 |
| application-vnd.iccprofile.pf                                                  | 1.936626e-04 | 2.703292e-10    | 1.644169e-05 |
| application-x-gdbm.db                                                          | 1.004576e-04 | 1.206046e-10    | 1.098201e-05 |
| msofficemacros.xlsm                                                            | 1.198410e-04 | 1.113049e-10    | 1.055011e-05 |
| application-winhelp.hlp                                                        | 3.341734e-04 | 8.613501e-10    | 2.934877e-05 |
| application-vnd.ms-msi.mst                                                     | 2.489434e-04 | 3.700494e-10    | 1.923667e-05 |
| application-x-xz.xz                                                            | 1.423150e-04 | 9.685737e-11    | 9.841614e-06 |
| application-vnd.ms-powerpoint.ppt                                              | 2.943916e-04 | 5.321082e-10    | 2.306747e-05 |
| application-vnd.openxmlformats-officedocument.spreadsheetml.sheet.xlsx         | 1.989454e-04 | 2.177364e-10    | 1.475589e-05 |
| application-x-dosexec.sys                                                      | 1.867478e-04 | 2.115706e-10    | 1.454547e-05 |
| text-x-makefile.ps                                                             | 5.021001e-03 | 1.305384e-07    | 3.613010e-04 |
| application-vnd.openxmlformats-officedocument.spreadsheetml.sheet.xlsm         | 1.894194e-04 | 3.072115e-10    | 1.752745e-05 |
| application-pgp-keys.key                                                       | 1.639323e-03 | 9.117884e-09    | 9.548761e-05 |
| text-plain.bat                                                                 | 1.673547e-03 | 6.595851e-09    | 8.121484e-05 |
| x-custom-mime-sylk.slk                                                         | 1.085199e-03 | 3.176089e-09    | 5.635680e-05 |
| application-zip.doc.zip                                                        | 8.826440e-05 | 1.094381e-10    | 1.046127e-05 |
| application-cdfv2-corrupt.vsmacros                                             | 2.797734e-04 | 7.889757e-10    | 2.808871e-05 |
| text-rtf.rtf                                                                   | 4.003238e-03 | 3.846898e-08    | 1.961351e-04 |
| application-x-ms-sdb.sdb                                                       | 7.479560e-05 | 1.832890e-10    | 1.353843e-05 |
| image-tiff.tiff                                                                | 4.037560e-05 | 3.937332e-11    | 6.274817e-06 |
| application-x-bittorrent.torrent                                               | 7.124540e-05 | 8.930078e-11    | 9.449909e-06 |
| inode-x-empty.md                                                               | 4.131200e-06 | 1.017987e-12    | 1.008953e-06 |
| application-vnd.ms-fontobject.h                                                | 7.611438e-04 | 1.274575e-08    | 1.128971e-04 |
| text-x-msdos-batch.bat                                                         | 3.532852e-04 | 6.910303e-10    | 2.628745e-05 |
| application-xml.conf                                                           | 3.541658e-04 | 7.762891e-10    | 2.786197e-05 |
| application-x-sharedlib.so                                                     | 1.549188e-04 | 4.808174e-10    | 2.192755e-05 |
| application-x-elc.elc                                                          | 1.365652e-04 | 1.226965e-10    | 1.107685e-05 |
| application-postscript.ps                                                      | 2.470156e-03 | 1.304539e-08    | 1.142164e-04 |
| application-vnd.oasis.opendocument.text.odt                                    | 1.115394e-04 | 1.084908e-10    | 1.041589e-05 |
| application-x-empty                                                            | 4.398200e-06 | 2.689637e-12    | 1.640011e-06 |
| application-vnd.openxmlformats-officedocument.presentationml.presentation.pptx | 1.637118e-04 | 2.511479e-10    | 1.584765e-05 |
| application-pgp-signature.gpg                                                  | 1.094120e-03 | 6.371242e-09    | 7.982006e-05 |
| application-x-compress.z                                                       | 7.190680e-05 | 2.044913e-10    | 1.430005e-05 |
| application-x-tar.tar                                                          | 1.731490e-04 | 4.801532e-10    | 2.191240e-05 |
| application-x-java-applet.class                                                | 5.933120e-05 | 7.010591e-11    | 8.372927e-06 |
| application-zip.nupkg                                                          | 1.308332e-04 | 2.196510e-10    | 1.482063e-05 |
| text-plain.js                                                                  | 5.468548e-03 | 2.857434e-08    | 1.690395e-04 |
| application-zip.zip                                                            | 2.418502e-04 | 8.029878e-10    | 2.833704e-05 |
| application-text-plain.cmd                                                     | 1.199812e-03 | 4.165233e-09    | 6.453862e-05 |
| text-x-shellscript                                                             | 1.130609e-03 | 3.030399e-09    | 5.504906e-05 |
| application-x-sqlite3.sqlite                                                   | 1.454530e-04 | 3.268226e-10    | 1.807824e-05 |
| application-pdf.pdf                                                            | 1.521896e-04 | 1.609169e-10    | 1.268530e-05 |
| application-x-bzip2.bz2                                                        | 9.058940e-05 | 1.284008e-10    | 1.133141e-05 |
| application-vnd.ms-opentype.otf                                                | 1.135066e-04 | 2.999704e-10    | 1.731965e-05 |
| x-custom-mime-windows-shortcut.lnk                                             | 1.166990e-04 | 3.158476e-10    | 1.777210e-05 |
| application-zip.war                                                            | 8.458760e-05 | 1.027855e-10    | 1.013832e-05 |
| text-plain.url                                                                 | 1.454770e-03 | 7.858186e-09    | 8.864641e-05 |
| application-x-java-keystore                                                    | 1.775944e-04 | 3.059879e-10    | 1.749251e-05 |
| text-plain.vbs                                                                 | 1.898345e-03 | 9.768017e-09    | 9.883328e-05 |

## small.mgc

| File                                                                           | Mean[s]      | Variance[s ^ 2] | STD[s]       |
| ------------------------------------------------------------------------------ | ------------ | --------------- | ------------ |
| text-x-powershell.ps1                                                          | 1.263736e-04 | 2.464276e-10    | 1.569801e-05 |
| image-png.png                                                                  | 4.582740e-05 | 3.778641e-11    | 6.147065e-06 |
| application-x-gnupg-keyring.gpg                                                | 3.535440e-05 | 2.742880e-11    | 5.237251e-06 |
| application-jar.jar                                                            | 6.927880e-05 | 6.170547e-11    | 7.855283e-06 |
| application-msword.doc                                                         | 1.136904e-04 | 1.801933e-10    | 1.342361e-05 |
| text-x-powershell.psd1                                                         | 7.158520e-05 | 1.021467e-10    | 1.010677e-05 |
| application-marc.md5sums                                                       | 3.516740e-05 | 3.844178e-11    | 6.200143e-06 |
| application-x-object.mod                                                       | 5.801660e-05 | 4.976512e-11    | 7.054440e-06 |
| text-x-powershell.psm1                                                         | 2.678864e-04 | 5.239415e-10    | 2.288977e-05 |
| application-cdfv2.db                                                           | 5.431640e-05 | 1.055255e-10    | 1.027256e-05 |
| application-vnd.iccprofile.pf                                                  | 3.401380e-05 | 3.312761e-11    | 5.755659e-06 |
| application-x-gdbm.db                                                          | 7.135380e-05 | 6.523063e-11    | 8.076548e-06 |
| msofficemacros.xlsm                                                            | 6.404760e-05 | 7.164213e-11    | 8.464168e-06 |
| application-winhelp.hlp                                                        | 8.524040e-05 | 7.310741e-11    | 8.550287e-06 |
| application-vnd.ms-msi.mst                                                     | 1.230300e-04 | 1.852283e-10    | 1.360986e-05 |
| application-x-xz.xz                                                            | 1.400346e-04 | 1.892738e-10    | 1.375768e-05 |
| application-vnd.ms-powerpoint.ppt                                              | 1.634864e-04 | 2.189142e-10    | 1.479575e-05 |
| application-vnd.openxmlformats-officedocument.spreadsheetml.sheet.xlsx         | 1.425782e-04 | 1.350923e-10    | 1.162292e-05 |
| application-x-dosexec.sys                                                      | 1.411308e-04 | 1.703961e-10    | 1.305359e-05 |
| text-x-makefile.ps                                                             | 8.372340e-05 | 7.493369e-11    | 8.656425e-06 |
| application-vnd.openxmlformats-officedocument.spreadsheetml.sheet.xlsm         | 1.318968e-04 | 1.308941e-10    | 1.144090e-05 |
| application-pgp-keys.key                                                       | 4.666200e-05 | 3.955176e-11    | 6.289019e-06 |
| text-plain.bat                                                                 | 4.061200e-05 | 3.762426e-11    | 6.133861e-06 |
| x-custom-mime-sylk.slk                                                         | 3.436300e-05 | 2.451363e-11    | 4.951124e-06 |
| application-zip.doc.zip                                                        | 3.758920e-05 | 3.794764e-11    | 6.160166e-06 |
| application-cdfv2-corrupt.vsmacros                                             | 1.526800e-04 | 2.486500e-10    | 1.576864e-05 |
| text-rtf.rtf                                                                   | 5.844992e-04 | 2.235072e-09    | 4.727655e-05 |
| application-x-ms-sdb.sdb                                                       | 3.507800e-05 | 3.409792e-11    | 5.839342e-06 |
| image-tiff.tiff                                                                | 3.404960e-05 | 3.175034e-11    | 5.634744e-06 |
| application-x-bittorrent.torrent                                               | 6.509000e-05 | 5.080470e-11    | 7.127742e-06 |
| inode-x-empty.md                                                               | 4.519200e-06 | 3.056431e-12    | 1.748265e-06 |
| application-vnd.ms-fontobject.h                                                | 3.772480e-05 | 5.174906e-11    | 7.193682e-06 |
| text-x-msdos-batch.bat                                                         | 4.139400e-05 | 1.307332e-10    | 1.143386e-05 |
| application-xml.conf                                                           | 4.713660e-05 | 1.811391e-10    | 1.345879e-05 |
| application-x-sharedlib.so                                                     | 4.314060e-05 | 2.915243e-11    | 5.399299e-06 |
| application-x-elc.elc                                                          | 9.570300e-05 | 5.542319e-11    | 7.444675e-06 |
| application-postscript.ps                                                      | 5.285080e-05 | 5.633334e-11    | 7.505554e-06 |
| application-vnd.oasis.opendocument.text.odt                                    | 6.175300e-05 | 3.932919e-11    | 6.271299e-06 |
| application-x-empty                                                            | 4.123400e-06 | 9.509724e-13    | 9.751782e-07 |
| application-vnd.openxmlformats-officedocument.presentationml.presentation.pptx | 1.043336e-04 | 8.258791e-11    | 9.087789e-06 |
| application-pgp-signature.gpg                                                  | 3.584800e-05 | 3.978930e-11    | 6.307876e-06 |
| application-x-compress.z                                                       | 3.191900e-05 | 2.089204e-11    | 4.570781e-06 |
| application-x-tar.tar                                                          | 5.547620e-05 | 2.855863e-11    | 5.344028e-06 |
| application-x-java-applet.class                                                | 3.919480e-05 | 2.610925e-11    | 5.109721e-06 |
| application-zip.nupkg                                                          | 7.130900e-05 | 7.849672e-11    | 8.859837e-06 |
| text-plain.js                                                                  | 1.997520e-04 | 1.722233e-10    | 1.312339e-05 |
| application-zip.zip                                                            | 1.392288e-04 | 1.037297e-10    | 1.018478e-05 |
| application-text-plain.cmd                                                     | 3.684080e-05 | 3.460466e-11    | 5.882572e-06 |
| text-x-shellscript                                                             | 8.508800e-05 | 7.286946e-11    | 8.536361e-06 |
| application-x-sqlite3.sqlite                                                   | 1.389450e-04 | 1.123408e-10    | 1.059909e-05 |
| application-pdf.pdf                                                            | 1.457780e-04 | 1.171011e-10    | 1.082133e-05 |
| application-x-bzip2.bz2                                                        | 3.382420e-05 | 5.586489e-11    | 7.474282e-06 |
| application-vnd.ms-opentype.otf                                                | 8.053020e-05 | 1.074611e-10    | 1.036634e-05 |
| x-custom-mime-windows-shortcut.lnk                                             | 3.492860e-05 | 3.578070e-11    | 5.981697e-06 |
| application-zip.war                                                            | 3.562640e-05 | 3.203682e-11    | 5.660108e-06 |
| text-plain.url                                                                 | 3.419620e-05 | 3.515891e-11    | 5.929495e-06 |
| application-x-java-keystore                                                    | 1.421380e-04 | 2.585138e-10    | 1.607836e-05 |
| text-plain.vbs                                                                 | 4.950420e-05 | 5.997918e-11    | 7.744623e-06 |
