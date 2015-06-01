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

createFinalHiddenFeaturesKernel(const float *weights,
    const float *movie_rating_probs, float* final_hidden_feature_probs,
    int num_movies, int num_hidden_features) {

    // weights[NUM_MOVIES][5][NUM_FEATURES]
    // movie_rating_probs[NUM_MOVIES][5]
    // final_hidden_feature_probs[NUM_FEATURES]
    unsigned int hidden_id = blockIdx.x * blockDim.x + threadIdx.x;
    unsigned int movie_id = 0;
    unsigned int rating = 0;
    float dot_prod; // Temporary, local dot product variable
    while (hidden_id < num_hidden_features) {
        dot_prod = 0.00; // Initialize the dot product to 0

        for (movie_id = 0; movie_id < num_movies; movie_id++) {
            for (rating = 0; rating < 5; rating++) {
                // Indexing: weights[movie_id][rating][feature_id]
                // movie_id - [1, 17771]
                // rating - [0, 4]
                // hidden_id - [0, 99]
                // Do the dot product
                dot_prod += weights[movie_id*5*num_hidden_features
                                    + rating*num_hidden_features
                                    + hidden_id]
                            * final_hidden_feature_probs[hidden_id];
            }
        }
        // Store the dot_product result
        final_hidden_feature_probs[hidden_id] = dot_prod;

        // Re-use this thread on another data point:
        hidden_id += blockDim.x * gridDim.x;
    }
}
