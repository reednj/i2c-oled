#!/bin/sh
#
# build the bcm .so file for use from ruby. This should really be a Makefile
# but since there is just one output and one source file, we just do it via
# a script
#

LIB_NAME=bcm2835

gcc -c -fPIC $LIB_NAME.c -o $LIB_NAME.o
gcc -shared -o $LIB_NAME.so $LIB_NAME.o
rm $LIB_NAME.o
