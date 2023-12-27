module ALPD41Network {
    sequence<byte> ByteArr;
    sequence<int> LongArr;

    const int ALP_DEFAULT = 0;

    // ----- enum ----

    enum AlpReturnCode {
        OK = 0,
        NOT_ONLINE = 1001,
        NOT_IDLE = 1002,
        NOT_AVAILABLE = 1003,
        NOT_READY = 1004,
        PARM_INVALID = 1005,
        ADDR_INVALID = 1006,
        MEMORY_FULL = 1007,
        SEQ_IN_USE = 1008,
        HALTED = 1009,
        ERROR_INIT = 1010,
        ERROR_COMM = 1011,
        DEVICE_REMOVED = 1012,
        NOT_CONFIGURED = 1013,
        LOADER_VERSION = 1014,
        ERROR_POWER_DOWN = 1018,
        DRIVER_VERSION = 1019,
        SDRAM_INIT = 1020,
        DEV_BUSY = 1100,
        DEV_READY = 1101,
        DEV_IDLE = 1102,
        PROJ_ACTIVE = 1200,
        PROJ_IDLE = 1201,
    };

    enum AlpDevInquireType {
        DEVICE_NUMBER = 2000,
        VERSION = 2001,
        DEV_STATE = 2002,
        DEV_DMDTYPE = 2021,
        AVAIL_MEMORY = 2003,
        TRIGGER_TIME_OUT = 2014,
        DDC_FPGA_TEMPERATURE = 2050,
        APPS_FPGA_TEMPERATURE = 2051,
        PCB_TEMPERATURE = 2052,
        DEV_DISPLAY_HEIGHT = 2057,
        DEV_DISPLAY_WIDTH = 2058,
    };

    enum AlpDevControlType {
        SYNCH_POLARITY = 2004,
        TRIGGER_EDGE = 2005,
        USB_CONNECTION = 2016,
        DEV_DMD_MODE = 2064,
        PWM_LEVEL = 2063,
    };

    const int LEVEL_HIGH = 2006;
    const int LEVEL_LOW = 2007;
    const int EDGE_FALLING = 2008;
    const int EDGE_RISING = 2009;
    const int TIME_OUT_ENABLE = 0;
    const int TIME_OUT_DISABLE = 1;
    const int DMD_POWER_FLOAT = 1;

    enum AlpDevDmdType {
        DMDTYPE_XGA = 1,
        DMDTYPE_SXGA_PLUS = 2,
        DMDTYPE_1080P_095A = 3,
        DMDTYPE_XGA_07A = 4,
        DMDTYPE_XGA_055A = 5,
        DMDTYPE_XGA_055X = 6,
        DMDTYPE_WUXGA_096A = 7,
        DMDTYPE_DISCONNECT = 255,
    }

    enum AlpSeqControlType {
        SEQ_REPEAT = 2100,
        FIRSTFRAME = 2101,
        LASTFRAME = 2102,
        BITNUM = 2103,
        BIN_MODE = 2104,
        PWM_MODE = 2107,
        DATA_FORMAT = 2110,
        SEQ_PUT_LOCK = 2119,
        FIRSTLINE = 2111,
        LASTLINE = 2112,
        LINE_INC = 2113,
        SCROLL_FROM_ROW = 2123,
        SCROLL_TO_ROW = 2124,
        DEV_DYN_SYNCH_OUT1_GATE = 2023,
        DEV_DYN_SYNCH_OUT2_GATE = 2024,
        DEV_DYN_SYNCH_OUT3_GATE = 2025,
        FLUT_MODE = 2118,
        FLUT_ENTRIES9 = 2120,
        FLUT_OFFSET9 = 2122,
    };

    const int BIN_NORMAL = 2105;
    const int BIN_UNINTERRUPTED = 2106;
    const int FLEX_PWM = 3;
    const int DATA_MSB_ALIGN = 0;
    const int DATA_LSB_ALIGN = 1;
    const int DATA_BINARY_TOPDOWN = 2;
    const int DATA_BINARY_BOTTOMUP = 3;
    const int FLUT_NONE = 0;
    const int FLUT_9BIT = 1;
    const int FLUT_18BIT = 2;
    const int SEQ_DMD_LINES = 2125;

    enum AlpSeqInquireType {
        BITPLANES = 2200,
        PICNUM = 2201,
        PICTURE_TIME = 2203,
        ILLUMINATE_TIME = 2204,
        SYNCH_DELAY = 2205,
        SYNCH_PULSEWIDTH = 2206,
        TRIGGER_IN_DELAY = 2207,
        MAX_SYNCH_DELAY = 2209,
        MAX_TRIGGER_IN_DELAY = 2210,
        MIN_PICTURE_TIME = 2211,
        MIN_ILLUMINATE_TIME = 2212,
        MAX_PICTURE_TIME = 2213,
        ON_TIME = 2214,
        OFF_TIME = 2215,
        FLUT_MODE = 2118,
        FLUT_ENTRIES9 = 2120,
        FLUT_OFFSET9 = 2122,
    };

    enum AlpProjInquireType {
        PROJ_MODE = 2300,
        PROJ_STEP = 2329,
        PROJ_INVERSION = 2306,
        PROJ_UPSIDE_DOWN = 2307,
        PROJ_STATE = 2400,
        FLUT_MAX_ENTRIES9 = 2324,
        PROJ_WAIT_UNTIL = 2323,
        PROJ_QUEUE_MODE = 2314,
        PROJ_QUEUE_ID = 2315,
        PROJ_QUEUE_MAX_AVAIL = 2316,
        PROJ_QUEUE_AVAIL = 2317,
        PROJ_PROGRESS = 2318,
    };


    const int MASTER = 2301;
    const int SLAVE = 2302;
    const int PROJ_SYNC = 2303;
    const int SYNCHRONOUS = 2304;
    const int ASYNCHRONOUS = 2305;
    const int PROJ_LEGACY = 0;
    const int PROJ_SEQUENCE_QUEUE = 1;
    const int PROJ_WAIT_PIC_TIME = 0;
    const int PROJ_WAIT_ILLU_TIME = 1;
    const int FLAG_QUEUE_IDLE = 1;
    const int FLAG_SEQUENCE_ABORTING = 2;
    const int FLAG_SEQUENCE_INDEFINITE = 4;
    const int FLAG_FRAME_FINISHED = 8;
    const int FLAG_RSVD0 = 16;

    enum AlpProjControlType {
        PROJ_MODE = 2300,
        PROJ_STEP = 2329,
        PROJ_INVERSION = 2306,
        PROJ_UPSIDE_DOWN = 2307,
        FLUT_WRITE_9BIT = 2325,
        FLUT_WRITE_18BIT = 2326,
        PROJ_QUEUE_MODE = 2314,
        PROJ_RESET_QUEUE = 2319,
        PROJ_ABORT_SEQUENCE = 2320,
        PROJ_ABORT_FRAME = 2321,
        PROJ_WAIT_UNTIL = 2323,
    };

    enum AlpLedType {
        HLD_PT120_RED = 0x0101,
        HLD_PT120_GREEN = 0x0102,
        HLD_PT120_BLUE = 0x0103,
        HLD_CBT120_UV = 0x0104,
        HLD_CBT90_WHITE = 0x0106,
        HLD_PT120TE_BLUE = 0x0107,
        HLD_CBT140_WHITE = 0x0108,
    };

    enum AlpLedControlType {
        LED_SET_CURRENT = 1001,
        LED_BRIGHTNESS = 1002,
        LED_FORCE_OFF = 1003,
    };

    const int LED_AUTO_OFF = 0;
    const int LED_OFF = 1;
    const int LED_ON = 2;

    enum AlpLedInquireType {
        LED_TYPE = 1101,
        LED_MEASURED_CURRENT = 1102,
        LED_TEMPERATURE_REF = 1103,
        LED_TEMPERATURE_JUNCTION = 1104,
        LED_ALLOC_PARAMS = 2101,
    };


    // ----- struct -----


    struct AlpDynSynchOutGate {
        byte Period;
        byte Polarity;
        ByteArr Gate;	// len=16
    };

    struct FlutWrite {
        int nOffset;
        int nSize;
        LongArr FrameNumbers;  // len=4096
    };

    struct AlpProjProgress {
        int CurrentQueueId;
        int SequenceId;
        int nWaitingSequences;
        int nSequenceCounter;
        int nSequenceCounterUnderflow;
        int nFrameCounter;
        int nPictureTime;
        int nFramesPerSubSequence;
        int nFlags;
    };

    struct AlpHldPt120AllocParams {
        int I2cDacAddr;
        int I2cAdcAddr;
    };

    exception AlpError {
        AlpReturnCode errNo;
    };

    // ----- function ------
    interface ALPD41 {
        LongArr listOpenDeviceId();
        void freeAllDevices();

        // ----- API Function -----
        int AlpDevAlloc(int DeviceNum, int InitFlag) throws AlpError;
        void AlpDevHalt(int DeviceId) throws AlpError;
        void AlpDevFree(int DeviceId) throws AlpError;
        void AlpDevControl(int DeviceId, AlpDevControlType ControlType, int ControlValue) throws AlpError;
        void AlpDevControlEx(int DeviceId, AlpDevControlType ControlType, AlpDynSynchOutGate UserStruct) throws AlpError;
        int AlpDevInquire(int DeviceId, AlpDevInquireType InquireType) throws AlpError;
        int AlpSeqAlloc(int DeviceId, int BitPlanes, int PicNum) throws AlpError;
        void AlpSeqFree(int DeviceId, int SequenceId) throws AlpError;
        void AlpSeqControl( int DeviceId, int SequenceId, AlpSeqControlType ControlType, int ControlValue) throws AlpError;
        void AlpSeqTiming(int DeviceId, int SequenceId, int IlluminateTime,  int PictureTime, int SynchDelay, int SynchPulseWidth, int TriggerInDelay) throws AlpError;
        int AlpSeqInquire(int DeviceId, int SequenceId, AlpSeqInquireType InquireType) throws AlpError;
        void AlpSeqPut(int DeviceId, int SequenceId, int PicOffset, int PicLoad, ByteArr UserArray) throws AlpError;
        void AlpProjStart(int DeviceId, int SequenceId) throws AlpError;
        void AlpProjStartCont(int DeviceId, int SequenceId) throws AlpError;
        void AlpProjHalt(int DeviceId) throws AlpError;
        void AlpProjWait(int DeviceId) throws AlpError;
        void AlpProjControl(int DeviceId, AlpProjControlType ControlType, int ControlValue) throws AlpError;
        void AlpProjControlEx(int DeviceId, AlpProjControlType ControlType, FlutWrite UserStruct) throws AlpError;
        int AlpProjInquire(int DeviceId, AlpProjInquireType InquireType) throws AlpError;
        AlpProjProgress AlpProjInquireEx(int DeviceId, AlpProjInquireType InquireType) throws AlpError;
        int AlpLedAlloc(int DeviceId, int LedType, AlpHldPt120AllocParams UserStruct) throws AlpError;
        void AlpLedFree(int DeviceId, int LedId) throws AlpError;
        void AlpLedControl(int DeviceId, int LedId, AlpLedControlType ControlType, int value) throws AlpError;
        int AlpLedInquire(int DeviceId, int LedId, AlpLedInquireType InquireType) throws AlpError;
        AlpHldPt120AllocParams AlpLedInquireEx(int DeviceId, int LedId, AlpLedInquireType InquireType) throws AlpError;
    };
}
