# Video Depth Map -- CS179 Project

Real-time video depth map generation using Python and CUDA.

### Run Instructions:

While in project root;

	python scripts/run_disparity.py <stereo-video>

	NOTE: stereo-video has to be located in $PROJECTROOT/videos/ subdirectory
		  video must also be a juxtapose stereo video pair

### Dependencies:

Pip-able dependencies are listed in `requirements.txt`. However, this project
also depends on OpenCV.

Using Python3.4, we chose to use OpenCV 3.0.0-rc1,
compiled from source on Ubuntu 15.04 (x64). The installation script, opencv.sh, 
is available in `misc/`. 
Script was obtained from https://help.ubuntu.com/community/OpenCV

NOTE: We recommend using a virtualenv to utilize the package. Using virtualenv, you will need to `pip install numpy` before running `pip install -r requirements.txt`.
