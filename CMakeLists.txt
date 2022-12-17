cmake_minimum_required(VERSION 3.18)

project(ALPD41Network)

link_directories("lib/")
include_directories("include/")

set(CMAKE_CXX_STANDARD 11)

find_program(GIT git)
find_program(NUGET nuget)

if(NOT NUGET)
    message(FATAL_ERROR "Could not find nuget command line tool.")
else()
    execute_process(COMMAND
        ${NUGET} install zeroc.ice.v140 -Version 3.7.8 -OutputDirectory ${CMAKE_SOURCE_DIR}/packages
        WORKING_DIRECTORY ${CMAKE_SOURCE_DIR}
        )
    set(Ice_HOME ${CMAKE_SOURCE_DIR}/packages/zeroc.ice.v140.3.7.8/)
endif()

if(NOT EXISTS "${Ice_HOME}")
    message(FATAL_ERROR "Could not find installed zeroc.ice.v140 package at ${Ice_HOME}!")
endif()

set(ICE_FILE "${CMAKE_CURRENT_SOURCE_DIR}/src/ALPD41.ice")

list(APPEND ICE_GENERATED_FILES
    "ALPD41.cpp"
    "ALPD41.h"
    )

find_package(Ice 3.7.0 
    REQUIRED COMPONENTS
    Ice++11
    IceDiscovery++11
    IceLocatorDiscovery++11
    IceSSL++11
    )

foreach(SLICE_DIR ${Ice_SLICE_DIRS})
    list(APPEND SLICE_INCLUDE_ARGS "-I${SLICE_DIR}")
endforeach()

add_custom_command(
    OUTPUT ${ICE_GENERATED_FILES}
    COMMAND ${Ice_SLICE2CPP_EXECUTABLE}
    ARGS "--underscore" "--checksum" ${SLICE_INCLUDE_ARGS} ${ICE_FILE}
    MAIN_DEPENDENCY ${ICE_FILE}
    COMMENT "Generating Ice files"
    VERBATIM
    )

add_executable(ALPD41Network
    "src/main.cpp"
    )

target_include_directories(ALPD41Network PRIVATE "${CMAKE_CURRENT_BINARY_DIR}")

add_compile_definitions(ICE_CPP11_MAPPING)

target_link_libraries(ALPD41Network
    PRIVATE
    "alpD41.lib"
    Ice::Ice++11
    Ice::IceDiscovery++11
    Ice::IceLocatorDiscovery++11
    Ice::IceSSL++11
    )

target_sources(ALPD41Network
    PRIVATE
    ${ICE_GENERATED_FILES}
    )

if (GIT)
    add_custom_command(
        OUTPUT "build_number.h"
        COMMAND
        ${CMAKE_COMMAND} -DGIT="${GIT}" -P ${CMAKE_SOURCE_DIR}/build_number.cmake
        )

    target_sources(ALPD41Network
        PRIVATE
        "build_number.h"
        )
endif()

