#include <math.h>

#include "computeInitialDisparity.h"
#include "computeHalfDisparity.cu"
#include "computeFullDisparity.cu"


__global__ void

eventScheduler(int img_height,
                    int img_width,
                    const float * pixelsFullR,
                    const float * pixelsHalfR,
                    const float * pixelsQuartR,
                    const float * pixelsFullL,
                    const float * pixelsHalfL,
                    const float * pixelsQuartL,
                    float * dQuarter,
                    float * dHalf,
                    float * disparityFull,
                    const int sFull,
                    const int img_width,
                    const int img_height,
                    const bool * foregroundFullR,
                    const bool * foregroundHalfR,
                    const bool * foregroundQuarterR,
                    const bool * foregroundFullL,
                    const bool * foregroundHalfL,
                    const bool * foregroundQuarterL)
{
    dim3 blockSize(8,64); //Each thread would be responsible for 8 pixels, so a block takes care of 64 * 64 pixels
    dim3 fullGridSize( celeing(img_height/64) ,celeing(img_width/64));
    dim3 halfGridSize( celeing(img_height/(64 * 2)) ,celeing(img_width/(64*2)));
    dim3 quartGridSize( celeing(img_height/(64 * 4)) ,celeing(img_width/(64*4)));

    computeInitialDisparity  <<<quartGridSize , blockSize>>>
                        (const float * pixelsFullR,
                        const float * pixelsHalfR,
                        const float * pixelsQuartR,
                        const float * pixelsFullL,
                        const float * pixelsHalfL,
                        const float * pixelsQuartL,
                        float * dQuarter,
                        float * dHalf,
                        float * disparityFull,
                        const int sFull,
                        const int img_width,
                        const int img_height,
                        const bool * foregroundFullR,
                        const bool * foregroundHalfR,
                        const bool * foregroundQuarterR,
                        const bool * foregroundFullL,
                        const bool * foregroundHalfL,
                        const bool * foregroundQuarterL);

    computeHalfDisparity  <<<halfGridSize, blockSize>>>
                    (const float * pixelsFullR,
                     const float * pixelsHalfR,
                     const float * pixelsFullL,
                     const float * pixelsHalfL,
                     float * dQuarter,
                     float * dHalf,
                     float * disparityFull,
                     const int img_width,
                     const int img_height,
                     const bool * foregroundFullR,
                     const bool * foregroundHalfR,
                     const bool * foregroundFullL,
                     const bool * foregroundHalfL);

    computeFullDisparity <<<fullGridSize, blockSize>>>
                    (const float * pixelsFullR,
                     const float * pixelsFullL,
                     float * dHalf,
                     float * disparityFull
                     const int img_width,
                     const int img_height,
                     const bool * foregroundFullR,
                     const bool * foregroundFullL);
}