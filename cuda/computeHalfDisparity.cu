#include <math.h>
#include "computeFullDisparity.cu"

#define IMAGE_HEIGHT 260
#define IMAGE_WIDTH 360

__global__ void

computeHalfDisparity(const float *** pixelsFullR,
                     const float *** pixelsHalfR,
                     const float *** pixelsFullL,
                     const float *** pixelsHalfL,
                     float ** dQuarter,
                     const bool ** foregroundFullR,
                     const bool ** foregroundHalfR,
                     const bool ** foregroundFullL,
                     const bool ** foregroundHalfL)
{
    float ** dHalf = new float * [IMAGE_HEIGHT/2];
    for (int k = 0; k < IMAGE_HEIGHT/2; k++)
    {
        dHalf[k] = new float [IMAGE_WIDTH/2];
    }

    for (int k = 0; k < IMAGE_HEIGHT/2; k++)
    {

        for (int i = 0; i < IMAGE_WIDTH/2; i++)
        {
            if (foregroundHalfL[k][i]==1)
            {
                float * matchingCost = new float [5];
                int prevdisp = (int) floorf(dQuarter[k/2][i/2]);
                int initial_j = (2* prevdisp) -2;
                int max_j = 0;
                for (int j = initial_j; j <= initial_j + 4; j++)
                {
                    if ( j+i >= IMAGE_WIDTH/4)
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
                                matchingCost[j - initial_j] = square(pixelsQuartL[k][i][m] - pixelsQuartR[k][i+j][m]);
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
                dHalf[k][i] = sqrt(curr_min);
                delete [] matchingCost;
            }
            else
            {
                dHalf[k][i] = 20;
            }
        }
    }
    computeFullDisparity(const float *** pixelsFullR,
                     const float *** pixelsFullL,
                     float ** dHalf,
                     const bool ** foregroundFullR,
                     const bool ** foregroundFullL);

    for (int i = 0; i < IMAGE_HEIGHT; i++)
    {
        delete [] disparityFull[i];
    }
    delete [] disparityFull;
}