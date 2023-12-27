import sys
import traceback
import Ice
import time
import cv2
import itertools
import numpy as np
import ALPD41Network

import matplotlib.pyplot as plt

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

    def get_text_img(text):
        img = np.zeros((768, 1024), dtype=np.uint8)

        size, baseline = cv2.getTextSize(text, cv2.FONT_HERSHEY_SIMPLEX, 12, 50)

        cv2.putText(img, text, (1024//2 - size[0]//2, 768//2 + size[1]//2), cv2.FONT_HERSHEY_SIMPLEX, 12, 255, 50)

        return img

    frames = 10
    repeat = 5
    img_series = np.zeros((frames, dmd_height, dmd_width), dtype=np.byte)

    # create an animation of a dark rotating ellipse on bright background
    for i in range(frames):
        img_series[i] = get_text_img(f"{i}")

    ts = time.time()
    print(f"Uploading sequence, frames: {frames}")
    seq_id = alp.AlpSeqAlloc(dev_id, 1, frames)
    alp.AlpSeqControl(dev_id, seq_id, ALPD41Network.AlpSeqControlType.FLUT_MODE, ALPD41Network.FLUT_18BIT)

    for b in range(0, frames, 1):
        alp.AlpSeqPut(dev_id, seq_id, b, 1, img_series[b:b+1].flatten())

    dt = time.time() - ts
    print(f"Uploading done, time elasped: {dt*1000} ms")

    alp.AlpSeqControl(dev_id, seq_id, ALPD41Network.AlpSeqControlType.BITNUM, 1)
    alp.AlpSeqControl(dev_id, seq_id, ALPD41Network.AlpSeqControlType.BIN_MODE, ALPD41Network.BIN_UNINTERRUPTED)

    alp.AlpProjControl(dev_id, ALPD41Network.AlpProjControlType.PROJ_MODE, ALPD41Network.MASTER)
    alp.AlpSeqTiming(dev_id, seq_id, 0, 250000, 0, 0, 0)

    # write FLUT

    flut = list(itertools.chain(*[(list(range(frames)) + list(reversed(range(frames)))) for i in range(repeat)]))

    alp.AlpProjControlEx(dev_id,
                         ALPD41Network.AlpProjControlType.FLUT_WRITE_18BIT,
                         ALPD41Network.FlutWrite(0, len(flut), flut))

    alp.AlpSeqControl(dev_id, seq_id, ALPD41Network.AlpSeqControlType.FLUT_ENTRIES9, len(flut)*2)

    print(f"FLUT entries written:", alp.AlpSeqInquire(dev_id, seq_id, ALPD41Network.AlpSeqInquireType.FLUT_ENTRIES9))

    alp.AlpProjStart(dev_id, seq_id)

    alp.AlpProjWait(dev_id)

    print(f"Projection finished")

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
