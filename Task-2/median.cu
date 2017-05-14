#include <stdio.h>
#include <cuda.h>
#include <getopt.h>
#include <assert.h>
#include <cuda_runtime_api.h>
#include "Bitmap.h"

__global__ void kernel(unsigned char *inputImage, unsigned char *outputImage, int width, int height, int radius)
{
	int row = blockIdx.y * blockDim.y + threadIdx.y;
	int col = blockIdx.x * blockDim.x + threadIdx.x;
    if (row >= height || col >= width) return;

	int hist[256];
    memset(hist, 0, sizeof(hist[0]) * 256);

	for (int i = -radius; i <= radius; ++i) { 
		for (int j = -radius; j <= radius; ++j){
            int x = row + i;
            int y = col + j;
            if (x < 0) x = -x;
            if (y < 0) y = -y;
            if (x >= height) x -= (x - height) * 2;
            if (y >= width)  y -= (y - width)  * 2;
			++hist[inputImage[x * width + y]];
		}
	}

    int bound = (2 * radius + 1) * (2 * radius + 1) / 2;
    int sum = 0;
    for (int i = 0; i < 256; ++i) {
        sum += hist[i];
        if (sum >= bound) {
            outputImage[row * width + col] = i;
            break;
        }
    }
}

void MedianFilter(Bitmap* image, Bitmap* outputImage, int radius, int blockSize) {
	int width  = image->Width();
	int height = image->Height();
	int size =  width * height * sizeof(char);

	unsigned char *deviceinputimage;
	assert(cudaSuccess == cudaMalloc((void**) &deviceinputimage, size));
    assert(cudaSuccess == cudaMemcpy(deviceinputimage, image->image, size, cudaMemcpyHostToDevice));

	unsigned char *deviceOutputImage;
	cudaMalloc((void**) &deviceOutputImage, size);

	dim3 dimBlock(blockSize, blockSize);
	dim3 dimGrid((width + blockSize - 1) / blockSize,
                (height + blockSize - 1) / blockSize);

	kernel<<<dimGrid, dimBlock>>>(deviceinputimage, deviceOutputImage, width, height, radius);

    assert(cudaSuccess == cudaMemcpy(outputImage->image, deviceOutputImage, size, cudaMemcpyDeviceToHost));
	cudaFree(deviceinputimage);
	cudaFree(deviceOutputImage);
}

void parse_argv(int argc, char *argv[], char **inputFname, char **outputFname, int *radius, int *blockSize)
{
    static struct option long_options[] =
    {
        {"inputImage",  required_argument, NULL, 'i'},
        {"outputImage", required_argument, NULL, 'o'},
        {"radius",      optional_argument, NULL, 'r'},
        {"blockSize",   optional_argument, NULL, 'b'},
        {NULL, 0, NULL, 0}
    };

    int ch = 0;
    while ((ch = getopt_long(argc, argv, "i:o:r:b:", long_options, NULL)) != -1) {
        switch (ch) {
             case 'i' : *inputFname = optarg;
                 break;
             case 'o' : *outputFname = optarg;
                 break;
             case 'r' : *radius = atoi(optarg);
                 break;
             case 'b' : *blockSize = atoi(optarg);
                 break;
             default:
                 abort();
        }
    }
}

int main(int argc, char *argv[])
{
    char *inputFname  = NULL; 
    char *outputFname = NULL;
    int blockSize = 16;
    int radius = 1;

    parse_argv(argc, argv, &inputFname, &outputFname, &radius, &blockSize);

	Bitmap* inputImage  = new Bitmap();
	Bitmap* outputImage = new Bitmap();

	inputImage->Load(inputFname);
    outputImage->Load(inputFname);

	MedianFilter(inputImage, outputImage, radius, blockSize);
	outputImage->Save(outputFname);
}
