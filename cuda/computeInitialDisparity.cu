#include <math.h>
#include "computeHalfDisparity.cu"

// #define IMAGE_HEIGHT 260
// #define img_width 360

__global__ void


// [260, 720, 3] 
// [260, 0-359, 3] would be LEFT [260, 360:719, 3] would be RIGHT

computeInitialDisparity(const float * pixelsFullR,
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

    int sQuart = sFull / 4.0; //sFull is the max window we would want for full res pixel block searching

    int ind_i = 8 * threadIdx.x + 64 * blockIdx.x;
    int ind_j = threadIdx.y + 64 * blockIdx.y;
    const int end_i = ind_i + 8;

    int i = ind_i + (img_width * ind_j);

    
    for (; i <end_i; i++)
    {
        if (foregroundQuarterL[i] == 1)
        {
            float * matchingCost = new float [sQuart];
            int max_j = 0;
            for (int j = i; j <= i + sQuart; j++)
            {
                if ( (i % (img_width/4) != 0) && ((j+i) % (img_width/4)  == 0) ) //Check if the index within windows is in pixel block row range
                {
                    break;
                }
                else
                {
                    if (foregroundQuarterR[i+j]==1)
                    {
                        matchingCost[j-i] = 0;
                        for (int m = 0; m < 3; m++)
                        {
                            matchingCost[j-i] += powf((pixelsQuartL[(3*i)+m] - pixelsQuartR[(3*(i+j))+m]), 2);
                        }
                        matchingCost[j-i] /= 3;
                        max_j = j-i;
                    }
                    else
                    {
                        matchingCost[j-i] = 1000;// might have to also update max_j
                    }
                }
            }
            float curr_min = 5000;
            for (int l = 0; l <= max_j; l++)
            {
                if (curr_min > matchingCost[l])
                {
                    curr_min = matchingCost[l];
                }
            }
            dQuarter[i] = sqrt(curr_min);
            delete [] matchingCost;
        }
        else
        {
            dQuarter[i] = 20; //Decide on what to do for this case
        }
    }
}