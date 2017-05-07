CC=nvcc
CFLAGS=-I/usr/local/cuda-8.0/include
LDFLAGS=-L${CUDA_HOME}/lib64 

all: jacobi

jacobi: jacobi.cu
	$(CC) -o jacobi $(CFLAGS) -arch sm_20 $(LDFLAGS) jacobi.cu
	
clean: 
	rm jacobi 
