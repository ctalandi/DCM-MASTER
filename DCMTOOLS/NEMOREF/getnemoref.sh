#!/bin/bash

# note that you also need xios2 for compiling the code
#  This NEMO revision was compiled and ran successfully with
# xios rev 1587 of http://forge.ipsl.jussieu.fr/ioserver/svn/XIOS/dev/dev_olga
# to be compiled out of the DCM structure.
#  NEMO fcm files should indicate the xios root directory
git clone --branch 4.2.3 https://forge.nemo-ocean.eu/nemo/nemo.git nemo_4.2.3
