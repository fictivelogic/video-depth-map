from os.path import abspath, dirname
import sys

sys.path.append(abspath(dirname(dirname(__file__))))

from utils.video_utils import (load_video_from_file_name,
                               get_stereo_frame_from_video_capture,
                               split_stereo_frame_into_left_and_right_frames,
                               compute_background_mask)

from utils.py_cuda_interface import cuda_compute_disparity
import numpy as np
import cv2



if __name__=='__main__':
    if len(sys.argv) == 2:
        video_filename = sys.argv[1]
    else:
        video_filename = 'Mukuge.avi'
    print('Loading {}...'.format(video_filename))
    video_obj = load_video_from_file_name(video_filename)
    success, stereo_image = get_stereo_frame_from_video_capture(video_obj)
    left_img, right_img = split_stereo_frame_into_left_and_right_frames(
        stereo_frame=stereo_image
    )
    print('Computing background mask...')
    bg_mask = compute_background_mask(left_img, right_img)
    print('Computing disparity on GPU...')
    disparity_img = cuda_compute_disparity(
        image_left=left_img,
        image_right=right_img,
        foreground_left=bg_mask,
        foreground_right=np.ones(shape=(left_img.shape[0:1]),
                                 dtype=np.uint8),
        window_size=20,
        block_shape=(512, 1, 1),
        grid_shape=(1024, 1, 1)
    )
    print('Got : ')
    print(disparity_img)
    print(np.amax(disparity_img))
    cv2.imshow('Image:', left_img)
    cv2.imshow('Disparity:', 5 * disparity_img.astype(np.uint8))
    bg_maskR = compute_background_mask(right_img, left_img)
    cv2.imshow('FG L Mask: ', bg_mask)
    cv2.imshow('FG R Mask: ', bg_maskR)
    cv2.waitKey(0)
    video_obj.release()

