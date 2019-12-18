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
 	cudaMalloc((void**)&cuvec1,cusize * sizeof(int));
 	int begin = 0;
 	int block = 32;
 	int grid = cusize/block;
 	while(begin < size){
		cudaStreamCreate(&stream1);
        	cudaStreamCreate(&stream2);
 		cudaMemcpyAsync(cuvec1, vec1 + begin, cusize * sizeof(int), cudaMemcpyHostToDevice,stream1);
 		kernel<<<grid,block,0,stream2>>>(cuvec1,cusize);
 		cudaMemcpyAsync(vec1 + begin, cuvec1, cusize*sizeof(int), cudaMemcpyDeviceToHost,stream1);
		cudaDeviceSynchronize();
		cudaStreamDestroy(stream1);
        	cudaStreamDestroy(stream2);
 		begin += cusize;
	 }
	 for(int i = 0; i < size; i++){
	 	cout << vec1[i] << " ";
	 }
	 return 0;
 }

