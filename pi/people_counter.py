# import the necessary packages
import datetime
import imutils
import time
import cv2

from picamera import PiCamera
from picamera.array import PiRGBArray

SENSITIVITY = 40 # 0-255, lower==more sensitive
state = ''
people = 0

# if the video argument is None, then we are reading from webcam
camera = PiCamera()
camera.resolution = (640, 480)
camera.framerate = 32
rawCapture = PiRGBArray(camera, size=(640,480))
time.sleep(1.0)

# initialize the first frame in the video stream
firstFrame = None

# loop over the frames of the video
for rawCapture in camera.capture_continuous(rawCapture, format="bgr", use_video_port=True):
    # grab the current frame and initialize the occupied/unoccupied
    # text
    text = "Unoccupied"

    frame = rawCapture.array
    rawCapture.truncate(0)

    # resize the frame, convert it to grayscale, and blur it
    gray = cv2.cvtColor(frame, cv2.COLOR_BGR2GRAY)
    gray = cv2.GaussianBlur(gray, (21, 21), 0)

    # if the first frame is None, initialize it
    if firstFrame is None:
        firstFrame = gray
        continue

    # compute the absolute difference between the current frame and
    # first frame
    frameDelta = cv2.absdiff(firstFrame, gray)
    thresh = cv2.threshold(frameDelta, SENSITIVITY, 255, cv2.THRESH_BINARY)[1]

    # dilate the thresholded image to fill in holes, then find contours
    # on thresholded image
    thresh = cv2.dilate(thresh, None, iterations=2)
    (cnts, _) = cv2.findContours(thresh.copy(), cv2.RETR_EXTERNAL,
                                 cv2.CHAIN_APPROX_SIMPLE)

    if len(cnts) == 0:
        state = ''
    # loop over the contours
    max_area = 1500
    for c in cnts:
        # if the contour is too small, ignore it
        if cv2.contourArea(c) < max_area:
            continue
        max_area = cv2.contourArea(c)

        # compute the bounding box for the contour, draw it on the frame,
        # and update the text
        (x, y, w, h) = cv2.boundingRect(c)
        frame_h, frame_w, frame_ch = frame.shape

        if (x+w < frame_w/4):
            cv2.rectangle(frame, (x, y), (x + w, y + h), (0, 255, 0), 2)
            text = "Left"
            if (state == 'r'):
                people -= 1
                print "People: ", people
                f = open('count.txt', 'w')
                f.write(str(people))
                f.close()
                state = ''
                break
            else:
                state = 'l'
        elif (x > (frame_w - frame_w/4)):
            cv2.rectangle(frame, (x, y), (x + w, y + h), (0, 255, 0), 2)
            text = "Right"
            if (state == 'l'):
                people += 1
                print "People: ", people
                f = open('count.txt', 'w')
                f.write(str(people))
                f.close()
                state = ''
                break
            else:
                state = 'r'

    # draw the text and timestamp on the frame
    # cv2.putText(frame, "Room Status: {}".format(text), (10, 20),
    #            cv2.FONT_HERSHEY_SIMPLEX, 0.5, (0, 0, 255), 2)
    # cv2.putText(frame,
    #            datetime.datetime.now().strftime("%A %d %B %Y %I:%M:%S%p"),
    #            (10, frame.shape[0] - 10),
    #            cv2.FONT_HERSHEY_SIMPLEX, 0.35, (0, 0, 255), 1)

    # show the frame and record if the user presses a key
    # cv2.imshow("Debug Feed", frame)

    # if the `q` key is pressed, break from the lop
    key = cv2.waitKey(1) & 0xFF
    if key == ord("q"):
        break

# cleanup the camera and close any open windows
camera.release()
cv2.destroyAllWindows()
