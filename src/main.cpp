#include <iostream>
#include <sstream>
#include <string>
#include <Ice/Ice.h>
#include "ALPD41I.h"
#include "build_number.h"

using namespace ALPD41Network;

static void show_usage(std::string name)
{
    std::cerr << "ZeroC-Ice Wrapper of ALP 4.1 API\n"
#ifdef GIT_BUILD_NUMBER
        << "(build rev. " << GIT_BUILD_NUMBER << ")\n"
#endif
        << "\n"
        << "Usage: " << name << " <option(s)> \n"
        << "Options:\n"
        << "\t-h,--help\t\tShow this help message\n"
        << "\t-b,--bind BIND\tSpecify the interface to bind to. Default: `*`, i.e. listen to all interface.\n"
        << "\t-p,--port PORT\tSpecify the port to bind to. Default: `5577`.\n"
        << "\tOther unused options will be passed to Ice. \n"
        << std::endl;
}
 
int main(int argc, char* argv[]) {
    std::string host = "*";
    int port = 5577;

    for (int i = 1; i < argc; ++i) {
        std::string arg = argv[i];
        if(arg == "-h" || arg == "--help") {
            show_usage(argv[0]);
            return 0;
        } else if(arg == "-b" || arg == "--bind") {
            if (i + 1 < argc) {
                host = argv[++i];
            } else {
                std::cerr << "-b/--bind option requires one argument." <<std::endl;
                return 1;
            }
        } else if(arg == "-p" || arg == "--port") {
            if (i + 1 < argc) {
                port = std::stoi(argv[++i]);
            } else {
                std::cerr << "-p/--port option requires one argument." <<std::endl;
                return 1;
            }
        }
    }

    std::ostringstream endpoint;
    endpoint << "tcp -h " << host << " -p " << port << " -z";

    auto props = Ice::createProperties(argc, argv);
    props->setProperty("Ice.MessageSizeMax", "10240");  // limit the message size to be 10M
    Ice::InitializationData initData;
    initData.properties = props;

    try {
        Ice::CommunicatorHolder ich(initData);
        std::cerr << "Bind to " << host << ":" << port << "." << std::endl;
        auto adapter = ich->createObjectAdapterWithEndpoints("ALPD41NetworkAdapter", endpoint.str());
        auto object = std::make_shared<ALPD41I>();
        adapter->add(object, Ice::stringToIdentity("ALPD41Network"));
        adapter->activate();
        ich->waitForShutdown();
    } catch (const std::exception& e) {
        std::cerr << e.what() << std::endl;
        return 1;
    }
    return 0;
}
