#include<cuda.h>
 #include<cstdio>
 #include<iostream>
 
 using namespace std;
 
 __global__ void kernel(int* vector1,int n){
 	int idx = blockIdx.x*blockDim.x + threadIdx.x;
 		if(idx < n){
 			vector1[idx] *= 2;
	 	}
	return;
 }
 
 __host__ int main(){
 	int *vec1 = NULL;
 	int *cuvec1 = NULL;
 	cudaStream_t stream1;
 	cudaStream_t stream2;
 	cudaStreamCreate(&stream1);
 	cudaStreamCreate(&stream2);
 	int size = 1600;
 	int cusize = 160;
 	cudaMallocHost(&vec1,size * sizeof(int));
 	for(int i = 0; i < size; i++){
 		vec1[i] = i;
	}
 	cudaMalloc((void**)&cuvec1, 2 * cusize * sizeof(int));
	cudaMemcpy(cuvec1, vec1, cusize * sizeof(int), cudaMemcpyHostToDevice);

 	int begin = cusize;
 	int block = 32;
	int useSeg = 1;
 	int grid = cusize/block;
 	while(begin < size){
		cudaStreamCreate(&stream1);
        	cudaStreamCreate(&stream2);
 		cudaMemcpyAsync(cuvec1 + (useSeg) * cusize, vec1 + begin, cusize * sizeof(int), cudaMemcpyHostToDevice,stream1);
 		kernel<<<grid,block,0,stream2>>>(cuvec1 + (1 - useSeg) * cusize,cusize);
 		cudaMemcpyAsync(vec1 + (begin - cusize), cuvec1 + (1 - useSeg) * cusize, cusize*sizeof(int), cudaMemcpyDeviceToHost,stream1);
		cudaDeviceSynchronize();
		cudaStreamDestroy(stream1);
        	cudaStreamDestroy(stream2);
 		begin += cusize;
		useSeg = 1 - useSeg;
	 }
		
	kernel<<<grid,block>>>(cuvec1 + (1 - useSeg) * cusize,cusize);
	cudaMemcpy(vec1 + (begin - cusize), cuvec1 + (1 - useSeg) * cusize, cusize*sizeof(int), cudaMemcpyDeviceToHost);
	 for(int i = 0; i < size; i++){
	 	cout << vec1[i] << " ";
	 }
	 return 0;
 }

