import sys
import traceback
import Ice
import time
import numpy as np
import ALPD41Network

# When importing it as a module from inside a module, it might be more convenient to use a hacky way:
# > from (...import path of Andor_ice.py file...).Andor_ice import _M_AndorNetwork as AndorNetwork

status = 0
ic = None
dev_id = None

try:
    ic = Ice.initialize(sys.argv)
    base = ic.stringToProxy("ALPD41Network:tcp -h 192.168.12.39 -p 5577")
    alp = ALPD41Network.ALPD41Prx.checkedCast(base)
    if not alp:
        raise RuntimeError("Invalid proxy")

    alp.freeAllDevices()

    dev_id = alp.AlpDevAlloc(0, 0)
    dmd_width = alp.AlpDevInquire(dev_id, ALPD41Network.AlpDevInquireType.DEV_DISPLAY_WIDTH)
    dmd_height = alp.AlpDevInquire(dev_id, ALPD41Network.AlpDevInquireType.DEV_DISPLAY_HEIGHT)

    print(f"DMD Width: {dmd_width} Height: {dmd_height}")


    def create_circular_mask(h, w, center=None, radius=None):
        if center is None: # use the middle of the image
            center = (int(w/2), int(h/2))
        if radius is None: # use the smallest distance between the center and image walls
            radius = min(center[0], center[1], w-center[0], h-center[1])

        Y, X = np.ogrid[:h, :w]
        dist_from_center = np.sqrt((X - center[0])**2 + (Y-center[1])**2)

        mask = dist_from_center <= radius
        return mask

    def create_elliptical_mask(h, w, a=1, b=1, theta=0, center=None, radius=None):
        if center is None: # use the middle of the image
            center = (int(w/2), int(h/2))
        if radius is None: # use the smallest distance between the center and image walls
            radius = min(center[0], center[1], w-center[0], h-center[1])

        Y, X = np.ogrid[:h, :w]
        X = X - center[0]
        Y = Y - center[1]
        dist_from_center = np.sqrt((X * np.cos(theta) - Y * np.sin(theta))**2/a**2
                                   + (X * np.sin(theta) +  Y * np.cos(theta))**2/b**2)

        mask = dist_from_center <= radius
        return mask

    def create_rect_mask(h, w, rect_h, rect_w, theta=0, center=None):
        if center is None: # use the middle of the image
            center = (int(w/2), int(h/2))

        Y, X = np.ogrid[:h, :w]
        X = X - center[0]
        Y = Y - center[1]
        mask = (np.abs(X * np.cos(theta) - Y * np.sin(theta)) <= rect_w/2) & (np.abs(X * np.sin(theta) +  Y * np.cos(theta)) <= rect_h/2)
        return mask

    frames = 20
    img_series = np.zeros((frames, dmd_height, dmd_width), dtype=np.byte)

    # create an animation of a dark rotating ellipse on bright background
    for i, theta in zip(range(frames), np.linspace(0, 2*np.pi, frames)):
        img = np.array(create_elliptical_mask(768, 1024, radius=100, theta=theta, a=1.5, b=1), dtype=int)
        img = 1 - img

        img_series[i] = np.array(img, dtype=np.byte)*255

    ts = time.time()
    print(f"Uploading sequence, frames: {frames}")
    seq_id = alp.AlpSeqAlloc(dev_id, 1, frames)
    for b in range(0, frames, 1):
        alp.AlpSeqPut(dev_id, seq_id, b, 1, img_series[b:b+1].flatten())

    alp.AlpSeqControl(dev_id, seq_id, ALPD41Network.AlpSeqControlType.BITNUM, 1)
    alp.AlpSeqControl(dev_id, seq_id, ALPD41Network.AlpSeqControlType.BIN_MODE, ALPD41Network.BIN_UNINTERRUPTED)
    alp.AlpSeqTiming(dev_id, seq_id, 0, 250000, 0, 0, 0)
    dt = time.time() - ts
    print(f"Uploading done, time elasped: {dt*1000} ms")

    #alp.AlpProjControl(dev_id, ALPD41Network.AlpProjControlType.PROJ_MODE, ALPD41Network.SLAVE)

    alp.AlpProjStartCont(dev_id, seq_id)

    try:
        while True:
            time.sleep(1)
    except KeyboardInterrupt:
        alp.AlpDevHalt(dev_id)

except:
    traceback.print_exc()
    status = 1

if ic:
    # Clean up
    try:
        if dev_id:
            dev_id = alp.AlpDevFree(dev_id)
        ic.destroy()
    except:
        traceback.print_exc()
        status = 1

sys.exit(status)
