// Simplified attempt
#define STARTING_MATCHING_COST 100.0f
struct pixel {
    float R;
    float G;
    float B;
};

__global__ void computeDisparity(
    const struct pixel * imageR, 
    const struct pixel * imageL,
    const int image_height,
    const int image_width,
    const char * foregroundR,
    const char * foregroundL,
    float * disparity_input,
    float * disparity_output)
{
    // Local variables:
    long int pixel_index = blockIdx.x * blockDim.x + threadIdx.x; // Index of current pixel
    float matching_cost = 0.0;
    float min_matching_cost = STARTING_MATCHING_COST;
    long int min_cost_offset = 0; 
    long int offset_pixel_index = 0;

    while(pixel_index < image_height * image_width) { 
        // while... the thread index hasn't gone outside the image dimensions
        if (true) { //foregroundL[pixel_index] == 1) {
            // Calculate matching cost for this foreground pixel
            // ensure that we are not going over the end of the pixel row
            offset_pixel_index = pixel_index;
            min_matching_cost = STARTING_MATCHING_COST;
            min_cost_offset = 0;
            for (int offset = 0; offset < window_size; offset++) { 
                if ((pixel_index % image_width) + offset >= image_width) {
                    break;
                }
                matching_cost =  powf(imageL[pixel_index].R - imageR[offset_pixel_index].R, 2);
                matching_cost += powf(imageL[pixel_index].G - imageR[offset_pixel_index].G, 2);
                matching_cost += powf(imageL[pixel_index].B - imageR[offset_pixel_index].B, 2);
                if (matching_cost < min_matching_cost) {
                    min_matching_cost = matching_cost; 
                    min_cost_offset = offset;
                }
                offset_pixel_index++;
            }

            if (min_matching_cost == STARTING_MATCHING_COST) {
                disparity_output[pixel_index] = 0;
            } else {
                disparity_output[pixel_index] = powf(min_cost_offset, 2); //  + image_width;
            }
        } else {
            disparity_output[pixel_index] = -1;
        }
        pixel_index += blockDim.x * gridDim.x;
    }
}

