#include <math.h>
#include "computeHalfDisparity.cu"

#define IMAGE_HEIGHT 260
#define IMAGE_WIDTH 360

__global__ void


// [260, 720, 3] 
// [260, 0-359, 3] would be LEFT [260, 360:719, 3] would be RIGHT

computeInitialDisparity(const float *** pixelsFullR,
                        const float *** pixelsHalfR,
                        const float *** pixelsQuartR,
                        const float *** pixelsFullL,
                        const float *** pixelsHalfL,
                        const float *** pixelsQuartL,
                        const int sFull,
                        const bool ** foregroundFullR,
                        const bool ** foregroundHalfR,
                        const bool ** foregroundQuarterR,
                        const bool ** foregroundFullL,
                        const bool ** foregroundHalfL,
                        const bool ** foregroundQuarterL)
{
    int sQuart = sFull / 4.0; //sFull is the max window we would want for full res pixel block searching
    float ** dQuarter = new float * [IMAGE_HEIGHT/4];
    for (int k = 0; k < IMAGE_HEIGHT/4; k++)
    {
        dQuarter[k] = new float [IMAGE_WIDTH/4];
    }
    
    for (int k = 0; k < IMAGE_HEIGHT/4; k++)
    {
        for (int i = 0; i < IMAGE_WIDTH/4; i++)
        {
            if (foregroundQuarterL[k][i] == 1)
            {
                float * matchingCost = new float [sQuart];
                int max_j = 0;
                for (int j = i; j <= i + sQuart; j++)
                {
                    if (j+i >= IMAGE_WIDTH/4) //Check if the index within windows is in pixel block row range
                    {
                        break;
                    }
                    else
                    {
                        if (foregroundQuarterR[k][i+j]==1)
                        {
                            matchingCost[j-i] = 0;
                            for (int m = 0; m < 3; m++)
                            {
                                matchingCost[j-i] += square(pixelsQuartL[k][i][m] - pixelsQuartR[k][i+j][m]);
                            }
                            matchingCost[j-i] /= 3;
                            max_j = j;
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
                dQuarter[k][i] = sqrt(curr_min);
                delete [] matchingCost;
            }
            else
            {
                dQuarter[k][i] = 20; //Decide on what to do for this case
            }
        }
    }
    
    computeHalfDisparity(const float *** pixelsFullR,
                     const float *** pixelsHalfR,
                     const float *** pixelsFullL,
                     const float *** pixelsHalfL,
                     float ** dQuarter,
                     const bool ** foregroundFullR,
                     const bool ** foregroundHalfR,
                     const bool ** foregroundFullL,
                     const bool ** foregroundHalfL);

    for (int i = 0; i < IMAGE_HEIGHT/4; i++)
    {
        delete [] dQuarter[i];
    }
    delete [] dQuarter;
}