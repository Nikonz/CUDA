CC=nvcc
CFLAGS=-I/usr/local/cuda-8.0/include
LDFLAGS=-L${CUDA_HOME}/lib64 

all: median

median: median.cu
	$(CC) -o median $(CFLAGS) -arch sm_20 $(LDFLAGS) median.cu

clean: 
	rm median
