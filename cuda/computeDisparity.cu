__global__ void


// [260, 720, 3] 
// [260, 0-359, 3] would be LEFT [260, 360:719, 3] would be RIGHT

computeDisparity(const Color * pixelsFullR,
                 const Color * pixelsHalfR,
                 const Color * pixelsQuartR,
                 const Color * pixelsFullL,
                 const Color * pixelsHalfL,
                 const Color * pixelsQuartL,
                 const int h,
                 const int v,
                 const int sFull,
                 const bool * foregroundFullR,
                 const bool * foregroundHalfR,
                 const bool * foregroundHQuarterR,
                 const bool * foregroundFullL,
                 const bool * foregroundHalfL,
                 const bool * foregroundHQuarterL,
                 float * disparityFull)
{
    //Determine indexes based on Thread ID's

    //Initial disparity measure calculated differently
    int sQuart = sFull / 4.0;
    int dQuarter[] = new int [h * v * 0.0625]; //Assuming h and v are divisible by 4
    
    for (int i = 0; i < (h*v * 0.0625); i++)
    {
        if (foregroundHQuarterL[i] == 1)
        {
            int matchingCost[] = new int [sQuart];
            for (int j = i; j < i + sQuart; j++)
            {
                if (j+i >= (i+1)*h * 0.25) //Check if the index within windows is in pixel block row range
                {
                    break;
                }
                else
                {
                    if (foregroundHQuarterR[i+j]==1)
                    {
                        matchingCost[j-i] = 3;//compute matching cost from openCV
                    }
                    else
                    {
                        matchingCost[j-i] = 1000; //Syntax?
                    }
                }
            }
            dQuarter[i] = min(matchingCost);
            delete [] matchingCost;
        }
        else
        {
            dQuarter[i] = 20; //Decide on what to do for this case
        }
    }

    int dHalf = new int [h*v* 0.25];
    for (int i = 0; i < (h * v * 0.25); i++)
    {
        if (foregroundHalfL[i] == 1)
        {
            int matchingCost[] = new int [4];
            int prevdisp = dQuarter[i/2]; //intentionally taking advantage of int division
            for (int j = 2 * prevdisp - 2; j < 2 * prevdisp + 2; j++)
            {
                if (j+i * h * 0.5)
                {
                    break;
                }
                else
                {
                    if (foregroundHalfR[j+i] == 1)
                    {
                        matchingCost[j - (2 * prevdisp - 2)] = 3; //compute matching cost
                    }
                    else
                    {
                        matchingCost[j - (2 * prevdisp - 2)] = 1000;
                    }
                }

            }
            dHalf[i] = min(matchingCost);
            delete [] matchingCost;
        }
        else {
            dHalf[i] = 20;
        }
    }

    //int disparityFull = new int [h*v* 0.25];
    for (int i = 0; i < (h * v); i++)
    {
        if (foregroundFullL[i] == 1)
        {
            int matchingCost[] = new int [4];
            int prevdisp = dHalf[i/2]; //intentionally taking advantage of int division
            for (int j = 2 * prevdisp - 2; j < 2 * prevdisp + 2; j++)
            {
                if (j+i * h)
                {
                    break;
                }
                else
                {
                    if (foregroundHalfR[j+i] == 1)
                    {
                        matchingCost[j - (2 * prevdisp - 2)] = 3; //compute matching cost
                    }
                    else
                    {
                        matchingCost[j - (2 * prevdisp - 2)] = 1000;
                    }
                }

            }
            disparityFull[i] = min(matchingCost);
            delete [] matchingCost;
        }
        else {
            disparityFull[i] = 20;
        }
    }

}

computeInitialDisparity(const float *** pixelsFullR,
                        const Color *** pixelsHalfR,
                        const Color *** pixelsQuartR,
                        const Color *** pixelsFullL,
                        const Color *** pixelsHalfL,
                        const Color *** pixelsQuartL,
                        const int sFull,
                        const bool ** foregroundFullR,
                        const bool ** foregroundHalfR,
                        const bool ** foregroundQuarterR,
                        const bool ** foregroundFullL,
                        const bool ** foregroundHalfL,
                        const bool ** foregroundQuarterL,
                        float * disparityFull)
{
    int sQuart = sFull / 4.0; //sFull is the max window we would want for full res pixel block searching
    float ** dQuarter = new int [h * v * 0.0625]; //Assuming h and v are divisible by 4
    
    for (int k = 0; k < IMAGE_HEIGHT/4; k++)
    {
        for (int i = 0; i < IMAGE_WIDTH/4; i++)
        {
            if (foregroundQuarterL[k][i] == 1)
            {
                int * matchingCost = new int [sQuart];
                int max_j = 0;
                for (int j = i; j < i + sQuart; j++)
                {
                    if (j+i >= (i+1)*h * 0.25) //Check if the index within windows is in pixel block row range
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
                                matchingCost[j-i] += square(pixelsQuartL[k][i][m] - pixelsQuartR[k][i+j][m]);
                            }
                            matchingCost[j-i] /= 3;
                            float tempCost = sqrt(matchingCost[j-i]);
                            matchingCost[j-i] = tempCost;
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
                dQuarter[k][i] = curr_min;
                delete [] matchingCost;
            }
            else
            {
                dQuarter[k][i] = 20; //Decide on what to do for this case
            }
        }
    }
}