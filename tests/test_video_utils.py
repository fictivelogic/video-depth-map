from os.path import join, abspath


def test_load_video_from_file_returns_correct_type():
    from utils.video_utils import load_video_from_file_name
    from cv2 import VideoCapture
    filename = 'Mukuge.avi'
    video_file = load_video_from_file_name(filename=filename)
    assert isinstance(video_file,  type(VideoCapture()))
    assert video_file.isOpened() == True, 'VideoCapture object was not opened.'


def test_get_next_stereo_image_from_video_returns_correct_type():
    from utils.video_utils import load_video_from_file_name
    from utils.video_utils import get_stereo_frame_from_video_capture
    from cv2 import VideoCapture
    import numpy as np
    filename = 'Mukuge.avi'
    video_object = load_video_from_file_name(filename=filename)
    return_status, stereo_frame = get_stereo_frame_from_video_capture(
        video_capture=video_object
    )
    assert return_status == True
    assert isinstance(stereo_frame,  np.ndarray)


def test_split_stereo_frame_returns_correct_numpy_arrays():
    from utils.video_utils import split_stereo_frame_into_left_and_right_frames
    import numpy as np
    stereo_dimensions = (640, 960, 3)  # Each frame is (640, 480, 3)
    stereo_frame = np.random.randn(640, 960, 3).astype(np.float32)
    test_stereo_frame = np.copy(stereo_frame)
    expected_left = stereo_frame[:, :480, :]
    expected_right = stereo_frame[:, 480:, :]
    test_left, test_right = split_stereo_frame_into_left_and_right_frames(
        stereo_frame=test_stereo_frame
    )
    np.testing.assert_array_equal(test_left, expected_left)
    np.testing.assert_array_equal(test_right, expected_right)
    
