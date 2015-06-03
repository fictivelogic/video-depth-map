CC=gcc

CUDA_PATH = /usr/local/cuda-7.0
CUDA_BIN_PATH = $(CUDA_PATH)/bin
CUDA_INC_PATH = $(CUDA_PATH)/include
CUDA_LIB_PATH = $(CUDA_PATH)/lib64

NVCC= $(CUDA_BIN_PATH)/nvcc
GENCODE_FLAGS  = -gencode arch=compute_20,code=sm_20 -gencode arch=compute_30,code=sm_30 -gencode arch=compute_35,code=sm_35
LD_FLAGS = #-L$(CUDA_LIB_PATH) -lrt -lcudart 
NVCC_FLAGS = -m64 -lib -shared -gencode arch=compute_50,code=sm_50


CFLAGS=-shared -fPIC

LDIR =lib

_TEST_SRC = $(wildcard tests/*.c)
TEST_LIBS = $(patsubst tests/%.c, %.so, $(_TEST_SRC))

_ALG_SRC = $(wildcard algorithms/*.c)
ALG_LIBS = $(patsubst algorithms/%.c, %.so, $(_ALG_SRC))

_CUDA_CU_SRC = $(wildcard cuda/*.cu)
CUDA_CU_OBJ = $(patsubst cuda/%.cu, %.o, $(_CUDA_CU_SRC))

_CUDA_SRC = $(wildcard cuda/*.c)
CUDA_LIBS = $(patsubst cuda/%.c, %.so, $(_CUDA_SRC))

_UTILS_SRC = $(wildcard utils/*.c)
UTILS_LIBS = $(patsubst utils/%.c, %.so, $(_UTILS_SRC))


all: tests algorithms utils cuda

nocuda: tests algorithms utils


$(TEST_LIBS):
	$(CC) $(CFLAGS) -o $(LDIR)/$@ $(patsubst %.so, tests/%.c, $@)

$(ALG_LIBS):
	$(CC) $(CFLAGS) -o $(LDIR)/$@ $(patsubst %.so, algorithms/%.c, $@)

$(UTILS_LIBS):
	$(CC) $(CFLAGS) -o $(LDIR)/$@ $(patsubst %.so, utils/%.c, $@)

$(CUDA_LIBS): $(CUDA_CU_OBJ)
	$(CC) $(CFLAGS) -o $(patsubst %.so, $(LDIR)/%.o, $@) $(patsubst %.so, cuda/%.c, $@)
	$(NVCC) $(NVCC_FLAGS) -o $(LDIR)/$@ -L$(CUDA_LIB_PATH) $(LDFLAGS) $(patsubst %.so, $(LDIR)/%.o, $@) $(patsubst %.o, $(LDIR)/%.o, $(CUDA_CU_OBJ)) 

$(CUDA_CU_OBJ): $(_CUDA_CU_SRC) 
	$(NVCC) $(NVCC_FLAGS) -I$(CUDA_INC_PATH) -o $(LDIR)/$@ -c $(patsubst %.o, cuda/%.cu, $@)

tests: $(TEST_LIBS)

algorithms: $(ALG_LIBS)

utils: $(UTILS_LIBS)

cuda: $(CUDA_CU_OBJ)

.PHONY: clean

# delete compiled libraries
clean:
	rm -f $(LDIR)/*.so $(LDIR)/*.o *~ 
