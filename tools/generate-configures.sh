#!/bin/bash

autoreconf -i

cp configure configure.win

sed -i '' 's|RSCRIPT="\${R_HOME}/bin/Rscript"|RSCRIPT="\${R_HOME}/bin/${R_ARCH_BIN}/Rscript.exe"|g' configure.win