

def test_compute_disparity_returns_expected_results():
    import pycuda.autoinit
    import pycuda.driver as drv
    import numpy as np
    from pycuda.compiler import SourceModule
    cuda_filename = 'cuda/computeDisparity.cu'
    cuda_kernel_source = open(cuda_filename, 'r').read()
    cuda_module = SourceModule(cuda_kernel_source)

    compute_disparity = cuda_module.get_function('computeDisparity')

    # Start with some small, known "image" array
    left  = np.random.randn(10).astype(np.float32)
    right = np.random.randn(10).astype(np.float32)

    # calculate the expected result of the kernel:
    expected_disparity = np.array([0, 1.2, 3.3, -4.3], dtype=np.float32)

    calculated_disparity = np.zeros_like(left) # Create the "calculated" as same shape as "left"

    compute_disparity(drv.Out(calculated_disparity), # drv.Out pulls the matrix from the GPU
                      drv.In(left),  # drv.In puts the array in GPU memory (handles all the 
                      drv.In(right)  # memory allocation for you)
                      )

    np.testing.assert_array_equal(calculated_disparity, 
                                  expected_disparity)



    
