from os.path import join, isfile
from utils.constants import VIDEO_DIR_PATH
from utils.exceptions import VideoProcessingError
import cv2


def load_video_from_file_name(filename):
    file_path = join(VIDEO_DIR_PATH, filename)
    if not isfile(file_path):
        raise FileNotFoundError(file_path)
    return cv2.VideoCapture(filename=file_path)


def get_stereo_frame_from_video_capture(video_capture):
    return_value = video_capture.grab()
    if not return_value:
        raise VideoProcessingError('Unable to perform video_capture.grab(),'+
                                   '\nReturned False.')
    return video_capture.retrieve()


def split_stereo_frame_into_left_and_right_frames(stereo_frame):
    single_frame_width = stereo_frame.shape[1]/2
    left_frame = stereo_frame[:, :single_frame_width, :]
    right_frame = stereo_frame[:, single_frame_width:, :]
    return left_frame, right_frame
    

def compute_background_mask(left_image, right_image):
    from cv2.bgsegm import createBackgroundSubtractorMOG
    from cv2 import dilate, erode, getStructuringElement
    bgSub = createBackgroundSubtractorMOG()
    bgSub.apply(left_image)
    bg_mask = bgSub.apply(right_image)
    # Dilate
    kernel = getStructuringElement(cv2.MORPH_RECT, (30, 30))
    dilated = dilate(bg_mask, kernel)
    return dilated
