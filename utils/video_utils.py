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
