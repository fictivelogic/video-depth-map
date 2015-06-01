from os.path import join, abspath


def test_load_video_from_file_returns_correct_type():
    from utils.video_utils import load_video_from_file_name
    from cv2 import VideoCapture
    filename = 'Mukuge.avi'
    video_file = load_video_from_file_name(filename=filename)
    assert isinstance(video_file,  type(VideoCapture()))
    assert video_file.isOpened() == True, 'VideoCapture object was not opened.'


def test_get_next_still_image_from_video_returns_correct_type():
    from utils.video_utils import load_video_from_file_name
    from utils.video_utils import get_still_frame_from_video_capture
    from cv2 import VideoCapture
    import numpy as np
    filename = 'Mukuge.avi'
    video_object = load_video_from_file_name(filename=filename)
    return_status, still_frame = get_still_frame_from_video_capture(
        video_capture=video_object
    )
    assert return_status == True
    assert isinstance(still_frame,  np.ndarray)


