#include <math.h>

#include "compute_disparity.cu"
// #include "computeHalfDisparity.cu"
// #include "computeFullDisparity.cu"

__global__ void eventScheduler(
    const struct pixel * imageR,
    const struct pixel * imageL,
    const int window_size,
    const int image_height,
    const int image_width,
    const bool * foregroundR,
    const bool * foregroundL,
    float * disparity_output)
{
    dim3 blockSize(8,64); //Each thread would be responsible for 8 pixels, so a block takes care of 64 * 64 pixels
    dim3 fullGridSize( celeing(image_height/64) ,celeing(image_width/64));

    computeDisparity <<<fullGridSize, blockSize>>>
    (imageR,
    imageL,
    window_size,
    image_height,
    image_width,
    foregroundR,
    foregroundL,
    disparity_output);
}