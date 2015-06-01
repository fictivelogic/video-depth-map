__global__ void


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
    int sQuart = sFull / 4;
    float dQuarter[] = new float [h * v * 0.0625]; //Assuming h and v are divisible by 4
    
    for (int i = 0; i < h*v; i++)
    {
        if foregroundHQuarterR[i] == 1
        {
            for (int j = 0; j < sQuart; j++)
            {
                if (j+i >= (i+1)*h)
                    break
                else
                {
                    if (foregroundHQuarterL[i+j]==1)
                    {
                        matchingCost[j] = //compute matching cost from openCV
                    }
                    else
                    {
                        matchingCost[j] = inf; //Syntax?
                    }
                }
            }
            dQuarter[i] = min(matchingCost);
        }
        else
            dQuarter[i] = 20; //Decide on what to do for this case
    }

}
