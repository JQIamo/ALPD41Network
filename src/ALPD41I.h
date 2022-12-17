#include <cinttypes>
#include <algorithm>
#include <vector>
#include <cassert>

#include "ALPD41.h" // Ice generated header
#include "alp.h" // Andor functions

namespace ALPD41Network {
    class ALPD41I : public ALPD41 {
    private:
        void checkErr(int _errno) {
            if (_errno != ALP_OK) {
                AlpError e;
                e.errNo = static_cast<AlpReturnCode>(_errno);
                throw e;
            }
        }

        std::vector<int32_t> open_alp_id;
    public:
        ALPD41I() : open_alp_id() {};

        std::vector<int32_t> listOpenDeviceId(const Ice::Current&) {
            return open_alp_id;
        }

        void freeAllDevices(const Ice::Current&) {
            for (int32_t dev_id : open_alp_id) {
                ::AlpDevFree(dev_id);
            }

            open_alp_id.clear();
        }

        int32_t AlpDevAlloc(int32_t DeviceNum, int32_t InitFlag, const Ice::Current&) {
            ALP_ID ret;

            checkErr(::AlpDevAlloc(DeviceNum, InitFlag, &ret));

            open_alp_id.push_back(ret);

            return ret;
        }

        void AlpDevHalt(int32_t DeviceId, const Ice::Current&) {
            checkErr(::AlpDevHalt(DeviceId));
        }

        void AlpDevFree(int32_t DeviceId, const Ice::Current&) {
            checkErr(::AlpDevFree(DeviceId));

            auto pos = std::find(open_alp_id.begin(), open_alp_id.end(), DeviceId);
            assert((pos != open_alp_id.end() && "DevicdId not in open_alp_id?"));

            open_alp_id.erase(pos);
        }

        void AlpDevControl(int32_t DeviceId, AlpDevControlType ControlType, int32_t ControlValue, const Ice::Current&) {
            checkErr(::AlpDevControl(DeviceId, static_cast<int32_t>(ControlType), ControlValue));
        }

        void AlpDevControlEx(int32_t DeviceId, AlpDevControlType ControlType, AlpDynSynchOutGate UserStruct, const Ice::Current&) {
            ::tAlpDynSynchOutGate user_struct;
            user_struct.Period = UserStruct.Period;
            user_struct.Polarity = UserStruct.Polarity;


            std::memset(user_struct.Gate, 0, sizeof user_struct.Gate);
            std::copy(UserStruct.Gate.begin(),
                    (UserStruct.Gate.size() <= 16) ? UserStruct.Gate.end() : UserStruct.Gate.begin() + 16,
                    user_struct.Gate);

            checkErr(::AlpDevControlEx(DeviceId, static_cast<int32_t>(ControlType), reinterpret_cast<void *>(&user_struct)));
        }

        int32_t AlpDevInquire(int32_t DeviceId, AlpDevInquireType InquireType, const Ice::Current&) {
            long ret;

            checkErr(::AlpDevInquire(DeviceId, static_cast<int32_t>(InquireType), &ret));

            return ret;
        }

        int32_t AlpSeqAlloc(int32_t DeviceId, int32_t BitPlanes, int32_t PicNum, const Ice::Current&) {
            ALP_ID ret;

            checkErr(::AlpSeqAlloc(DeviceId, BitPlanes, PicNum, &ret));

            return ret;
        }

        void AlpSeqFree(int32_t DeviceId, int32_t SequenceId, const Ice::Current&) {
            checkErr(::AlpSeqFree(DeviceId, SequenceId));
        }

        void AlpSeqControl(int32_t DeviceId, int32_t SequenceId, AlpSeqControlType ControlType, int32_t ControlValue, const Ice::Current&) {
            checkErr(::AlpSeqControl(DeviceId, SequenceId, static_cast<int32_t>(ControlType), ControlValue));
        }

        void AlpSeqTiming(int32_t DeviceId, int32_t SequenceId, int32_t IlluminateTime, int32_t PictureTime, int32_t SynchDelay, int32_t SynchPulseWidth, int32_t TriggerInDelay, const Ice::Current&) {
            checkErr(::AlpSeqTiming(DeviceId,
                        SequenceId,
                        IlluminateTime,
                        PictureTime,
                        SynchDelay,
                        SynchPulseWidth,
                        TriggerInDelay));
        }

        int32_t AlpSeqInquire(int32_t DeviceId, int32_t SequenceId, AlpSeqInquireType InquireType, const Ice::Current&) {
            long ret;

            checkErr(::AlpSeqInquire(DeviceId, SequenceId, static_cast<int32_t>(InquireType), &ret));

            return ret;
        }

        void AlpSeqPut(int32_t DeviceId, int32_t SequenceId, int32_t PicOffset, int32_t PicLoad, ByteArr UserArray, const Ice::Current&) {
            checkErr(::AlpSeqPut(DeviceId, SequenceId, PicOffset, PicLoad, reinterpret_cast<void *>(UserArray.data())));
        }

        void AlpProjStart(int32_t DeviceId, int32_t SequenceId, const Ice::Current&) {
            checkErr(::AlpProjStart(DeviceId, SequenceId));
        }

        void AlpProjStartCont(int32_t DeviceId, int32_t SequenceId, const Ice::Current&) {
            checkErr(::AlpProjStartCont(DeviceId, SequenceId));
        }

        void AlpProjHalt(int32_t DeviceId, const Ice::Current&) {
            checkErr(::AlpProjHalt(DeviceId));
        }

        void AlpProjWait(int32_t DeviceId, const Ice::Current&) {
            checkErr(::AlpProjWait(DeviceId));
        }

        void AlpProjControl(int32_t DeviceId, AlpProjControlType ControlType, int32_t ControlValue, const Ice::Current&) {
            checkErr(::AlpProjControl(DeviceId, static_cast<int32_t>(ControlType), ControlValue));
        }

        void AlpProjControlEx(int32_t DeviceId, AlpProjControlType ControlType, FlutWrite UserStruct, const Ice::Current&) {
            ::tFlutWrite user_struct;
            user_struct.nOffset = UserStruct.nOffset;
            user_struct.nSize = UserStruct.nSize;

            std::memset(user_struct.FrameNumbers, 0, sizeof user_struct.FrameNumbers);

            std::copy(UserStruct.FrameNumbers.begin(),
                    (UserStruct.FrameNumbers.size() <= 4096) ? UserStruct.FrameNumbers.end() : UserStruct.FrameNumbers.begin() + 4096,
                    user_struct.FrameNumbers);

            checkErr(::AlpProjControlEx(DeviceId, static_cast<int32_t>(ControlType), reinterpret_cast<void *>(&user_struct)));
        }

        int32_t AlpProjInquire(int32_t DeviceId, AlpProjInquireType InquireType, const Ice::Current&) {
            long ret;

            checkErr(::AlpProjInquire(DeviceId, static_cast<int32_t>(InquireType), &ret));

            return ret;
        }

        AlpProjProgress AlpProjInquireEx(int32_t DeviceId, AlpProjInquireType InquireType, const Ice::Current&) {
            ::tAlpProjProgress ret;

            checkErr(::AlpProjInquireEx(DeviceId, static_cast<int32_t>(InquireType), &ret));

            AlpProjProgress val {
                static_cast<int32_t>(ret.CurrentQueueId),
                static_cast<int32_t>(ret.SequenceId),
                static_cast<int32_t>(ret.nWaitingSequences),
                static_cast<int32_t>(ret.nSequenceCounter),
                static_cast<int32_t>(ret.nSequenceCounterUnderflow),
                static_cast<int32_t>(ret.nFrameCounter),
                static_cast<int32_t>(ret.nPictureTime),
                static_cast<int32_t>(ret.nFramesPerSubSequence),
                static_cast<int32_t>(ret.nFlags)
            };

            return val;
        }

        int32_t AlpLedAlloc(int32_t DeviceId, int32_t LedType, AlpHldPt120AllocParams UserStruct, const Ice::Current&) {
            ::tAlpHldPt120AllocParams user_struct {
                static_cast<int32_t>(UserStruct.I2cDacAddr),
                static_cast<int32_t>(UserStruct.I2cDacAddr)
            };
            ALP_ID ret;

            checkErr(::AlpLedAlloc(DeviceId, LedType, &user_struct, &ret));

            return ret;
        }

        void AlpLedFree(int32_t DeviceId, int32_t LedId, const Ice::Current&) {
            checkErr(::AlpLedFree(DeviceId, LedId));
        }

        void AlpLedControl(int32_t DeviceId, int32_t LedId, AlpLedControlType ControlType, int32_t Value, const Ice::Current&) {
            checkErr(::AlpLedControl(DeviceId, LedId, static_cast<int32_t>(ControlType), Value));
        }

        int32_t AlpLedInquire(int32_t DeviceId, int32_t LedId, AlpLedInquireType InquireType, const Ice::Current&) {
            long ret;

            checkErr(::AlpLedInquire(DeviceId, LedId, static_cast<int32_t>(InquireType), &ret));

            return ret;
        }

        AlpHldPt120AllocParams AlpLedInquireEx(int32_t DeviceId, int32_t LedId, AlpLedInquireType InquireType, const Ice::Current&) {
            ::tAlpHldPt120AllocParams ret;

            checkErr(::AlpLedInquireEx(DeviceId, LedId, static_cast<int32_t>(InquireType), &ret));

            AlpHldPt120AllocParams val {
                ret.I2cDacAddr,
                ret.I2cDacAddr
            };

            return val;
        }
    };
}
