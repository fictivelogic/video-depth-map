

def cuda_compute_disparity(image_right, image_left,
                           window_size, foreground_right,
                           foreground_left,
                           block_shape=(32, 1, 1),
                           grid_shape=(1, 1, 1)):
    assert image_left.shape == image_right.shape
    import pycuda.autoinit
    import pycuda.driver as drv
    from pycuda.compiler import SourceModule
    import numpy as np
    cuda_filename = 'cuda/compute_disparity.cu'
    cuda_kernel_source = open(cuda_filename, 'r').read()
    cuda_module = SourceModule(cuda_kernel_source)
    compute_disparity = cuda_module.get_function('computeDisparity')

    img_height = image_left.shape[0]
    img_width = image_left.shape[1]

    calculated_disparity = np.zeros(shape=(img_height, img_width), dtype=np.float32)
    compute_disparity(
        drv.In(image_left),
        drv.In(image_right),
        np.int32(window_size),
        np.int32(img_height),
        np.int32(img_width),
        drv.In(foreground_right),
        drv.In(foreground_left),
        drv.Out(calculated_disparity),
        block=block_shape,
        grid=grid_shape
    )
    return calculated_disparity
