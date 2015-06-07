import numpy as np
import cv2
import math


def cuda_compute_disparity(image_right, image_left,
                           window_size, foreground_right,
                           foreground_left,
                           block_shape=(32, 1, 1),
                           grid_shape=(1, 1, 1)):
    assert image_left.shape == image_right.shape
    if image_left.dtype == np.uint8:
        print('converting Uint8 image to float32')
        image_left = image_left.astype(np.float32)
        image_right = image_right.astype(np.float32)
    import pycuda.autoinit
    import pycuda.driver as drv
    from pycuda.compiler import SourceModule

    #Making lower resolution right and left images

    image_left_half = cv2.resize(image_left, dsize = (image_left.shape[0]//2, image_left.shape[1]//2))
    image_right_half = cv2.resize(image_right, dsize = (image_right.shape[0]//2, image_right.shape[1]//2))
    image_left_quarter = cv2.resize(image_left_half, dsize = (image_left_half.shape[0]//2, image_left_half.shape[1]//2))
    image_right_quarter = cv2.resize(image_right_half, dsize = (image_right_half.shape[0]//2, image_right_half.shape[1]//2))

    cuda_filename = 'cuda/compute_disparity.cu'
    cuda_kernel_source = open(cuda_filename, 'r').read()
    cuda_module = SourceModule(cuda_kernel_source)
    compute_disparity = cuda_module.get_function('computeDisparity')

    cuda_filename = 'cuda/compute_disparity_higher.cu'
    cuda_kernel_source = open(cuda_filename, 'r').read()
    cuda_module = SourceModule(cuda_kernel_source)
    compute_disparity_higher = cuda_module.get_function('computeDisparityHigher')


    img_height = image_left_quarter.shape[0]
    img_width = image_left_quarter.shape[1]

    calculated_disparity = np.zeros(shape=(img_height, img_width), dtype=np.float32)
    compute_disparity(
        drv.In(image_left_quarter),
        drv.In(image_right_quarter),
        np.int32(window_size),
        np.int32(img_height),
        np.int32(img_width),
        drv.In(foreground_right),
        drv.In(foreground_left),
        drv.Out(calculated_disparity),
        block=block_shape,
        grid=( math.ceil(grid_shape[0]/16), grid_shape[1], grid_shape[2])
    )

    lower_res_diaparity = calculated_disparity

    img_height = image_left_half.shape[0]
    img_width = image_left_half.shape[1]

    calculated_disparity_higher = np.zeros(shape=(img_height, img_width), dtype=np.float32)
    compute_disparity(
        drv.In(image_left_half),
        drv.In(image_right_half),
        np.int32(img_height),
        np.int32(img_width),
        drv.In(foreground_right),
        drv.In(foreground_left),
        drv.In(lower_res_diaparity),
        drv.Out(calculated_disparity),
        block=block_shape,
        grid=( math.ceil(grid_shape[0]/4), grid_shape[1], grid_shape[2])
    )

    lower_res_diaparity = calculated_disparity

    img_height = image_left.shape[0]
    img_width = image_left.shape[1]

    calculated_disparity_higher = np.zeros(shape=(img_height, img_width), dtype=np.float32)
    compute_disparity(
        drv.In(image_left),
        drv.In(image_right),
        np.int32(img_height),
        np.int32(img_width),
        drv.In(foreground_right),
        drv.In(foreground_left),
        drv.In(lower_res_diaparity),
        drv.Out(calculated_disparity),
        block=block_shape,
        grid= grid_shape
    )

    return calculated_disparity
