#include <math.h>

#define IMAGE_HEIGHT 260
#define IMAGE_WIDTH 360

__global__ void

computeFullDisparity(const float * pixelsFullR,
                     const float * pixelsFullL,
                     float * dHalf,
                     float * disparityFull
                     const bool * foregroundFullR,
                     const bool * foregroundFullL)
{
    for (int i = 0; i < IMAGE_WIDTH * IMAGE_HEIGHT; i++)
    {
        if (foregroundFullL[i]==1)
        {
            float * matchingCost = new float [5];
            int k = ((i/IMAGE_WIDTH)/2) + ((i%IMAGE_WIDTH)/2);
            int prevdisp = (int) floorf(dHalf[k]);
            int initial_j = (2* prevdisp) -2;
            int max_j = 0;
            for (int j = initial_j; j <= initial_j + 4; j++)
            {
                if ( (i % IMAGE_WIDTH != 0) && ((j+i) % IMAGE_WIDTH  == 0) )
                {
                    break;
                }
                else
                {
                    if (foregroundFullR[i+j] == 1)
                    {
                        matchingCost[j - initial_j] = 0;
                        for (int m = 0; m < 3; m++)
                        {
                            matchingCost[j - initial_j] = square(pixelsQuartL[(3*i) + m] - pixelsQuartR[(3*(i+j)) +m]);
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
            disparityFull[i] = sqrt(curr_min);
            delete [] matchingCost;
        }
        else
        {
            disparityFull[i] = 20;
        }
    }
    //copy to CPU mem
}