# vim:set ts=8 sw=8 sts=0 noet:

#  * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * */
#    File:         Makefile                                                  */
#    Description:  Makefile for programs running a simple k-means clustering */
#                  algorithm                                                 */
#                                                                            */
#    Author:  Wei-keng Liao                                                  */
#             ECE Department Northwestern University                         */
#             email: wkliao@ece.northwestern.edu                             */
#    Copyright, 2005, Wei-keng Liao                                          */
#                                                                            */
#  * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * */

# Copyright (c) 2005 Wei-keng Liao
# Copyright (c) 2011 Serban Giuroiu
#
# Permission is hereby granted, free of charge, to any person obtaining a copy
# of this software and associated documentation files (the "Software"), to deal
# in the Software without restriction, including without limitation the rights
# to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
# copies of the Software, and to permit persons to whom the Software is
# furnished to do so, subject to the following conditions:
#
# The above copyright notice and this permission notice shall be included in
# all copies or substantial portions of the Software.
#
# THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
# IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
# FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
# AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
# LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
# OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN
# THE SOFTWARE.

# ------------------------------------------------------------------------------

.KEEP_STATE:

all: seq omp cuda mpi

DFLAGS      =
OPTFLAGS    = -O -NDEBUG
OPTFLAGS    = -g -pg
INCFLAGS    = -I.
CFLAGS      = $(OPTFLAGS) $(DFLAGS) $(INCFLAGS) -DBLOCK_SHARED_MEM_OPTIMIZATION=1
NVCCFLAGS   = $(CFLAGS) --ptxas-options=-v
LDFLAGS     = $(OPTFLAGS)
LIBS        =

# please check the compile to the one you use and the openmp flag
# Here, I am using gcc and its openmp compile flag is -fopenmp
# If icc is used, please us -opnemp
#
OMPFLAGS    = -fopenmp

CC          = gcc
MPICC       = mpicc
NVCC        = nvcc

.c.o:
	$(CC) $(CFLAGS) -c $<

H_FILES     = kmeans.h

# ------------------------------------------------------------------------------
# CUDA Version

%.o : %.cu
	$(NVCC) $(NVCCFLAGS) -o $@ -c $<

CUDA_C_SRC = 'sample/cuda_main.cu' 'include/kmean/cuda_io.cu' 'include/kmean/cuda_wtime.cu'
CUDA_CU_SRC = 'include/kmean/cuda_kmeans.cu'

CUDA_C_OBJ = $(CUDA_C_SRC:%.cu=%.o)
CUDA_CU_OBJ = $(CUDA_CU_SRC:%.cu=%.o)

cuda: sample/cuda_main
cuda_main: $(CUDA_C_OBJ) $(CUDA_CU_OBJ)
	$(NVCC) $(LDFLAGS) -o $@ $(CUDA_C_OBJ) $(CUDA_CU_OBJ)

#---------------------------------------------------------------------
clean:
	rm -rf *.o omp_main seq_main mpi_main cuda_main \
	       core* .make.state gmon.out     \
               *.cluster_centres *.membership \
               Image_data/*.cluster_centres   \
               Image_data/*.membership        \
               profiles/
