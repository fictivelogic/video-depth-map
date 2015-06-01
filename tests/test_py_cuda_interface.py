

def test_python_can_call_cuda_kernel():
    import pycuda.autoinit
    import pycuda.driver as drv
    import numpy as np
    from pycuda.compiler import SourceModule
    mod = SourceModule(open('tests/multiply_them.cu', 'r').read())

    multiply_them = mod.get_function('multiply_them')

    test_size = 400
    a = np.random.randn(test_size).astype(np.float32)
    b = np.random.randn(test_size).astype(np.float32)

    dest = np.zeros_like(a)
    multiply_them(drv.Out(dest), drv.In(a), drv.In(b),
                  block=(test_size, 1, 1), grid=(1, 1))

    expected_product = np.array(a * b, dtype=np.float32)
    np.testing.assert_array_equal(dest, expected_product)



