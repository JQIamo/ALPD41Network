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

    frames = 5
    img_series = np.zeros((5, dmd_height, dmd_width), dtype=np.byte)

    strip_height = int(dmd_height / frames)
    for i in range(1, frames):
        img = np.zeros((dmd_height, dmd_width), dtype=np.byte)
        img[(i-1)*strip_height:i*strip_height] = np.ones((int(dmd_height / frames), dmd_width), dtype=np.byte)*255

        img_series[i] = img
    
    seq_id = alp.AlpSeqAlloc(dev_id, 1, frames)
    alp.AlpSeqPut(dev_id, seq_id, 0, frames, img_series.flatten())
    alp.AlpSeqTiming(dev_id, seq_id, 0, 200000, 0, 0, 0)
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
