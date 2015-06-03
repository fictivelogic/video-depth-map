#include <math.h>
#include "computeFullDisparity.cu"

#define IMAGE_HEIGHT 260
#define IMAGE_WIDTH 360

__global__ void

computeHalfDisparity(const float * pixelsFullR,
                     const float * pixelsHalfR,
                     const float * pixelsFullL,
                     const float * pixelsHalfL,
                     float * dQuarter,
                     float * dHalf,
                     float * disparityFull,
                     const bool * foregroundFullR,
                     const bool * foregroundHalfR,
                     const bool * foregroundFullL,
                     const bool * foregroundHalfL)
{

    for (int i = 0; i < IMAGE_WIDTH * IMAGE_HEIGHT/4; i++)
    {
        if (foregroundHalfL[i]==1)
        {
            float * matchingCost = new float [5];
            int k = ((i/(IMAGE_WIDTH/2) )/2) + ((i%(IMAGE_WIDTH/2) )/2);
            int prevdisp = (int) floorf(dQuarter[k]);
            int initial_j = (2* prevdisp) -2;
            int max_j = 0;
            for (int j = initial_j; j <= initial_j + 4; j++)
            {
                if ( (i % (IMAGE_WIDTH/2) != 0) && ((j+i) % (IMAGE_WIDTH/4)  == 0) )
                {
                    break;
                }
                else
                {
                    if (foregroundHalfR[i+j] == 1)
                    {
                        matchingCost[j - initial_j] = 0;
                        for (int m = 0; m < 3; m++)
                        {
                            matchingCost[j - initial_j] = square(pixelsQuartL[(3 * i) + m] - pixelsQuartR[(3*(i+j)) + m]);
                        }
                        matchingCost[j - initial_j] /= 3;
                        max_j = j - initial_j;
                    }
                    else
                    {
                        matchingCost[j - initial_j] = 1000;
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
            dHalf[i] = sqrt(curr_min);
            delete [] matchingCost;
        }
        else
        {
            dHalf[i] = 20;
        }
    }

    computeFullDisparity(const float * pixelsFullR,
                     const float * pixelsFullL,
                     float * dHalf,
                     float * disparityFull,
                     const bool * foregroundFullR,
                     const bool * foregroundFullL);

}