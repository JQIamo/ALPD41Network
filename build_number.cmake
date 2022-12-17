execute_process(
    COMMAND
    ${GIT} describe --tags
    OUTPUT_VARIABLE GIT_BUILD_NUMBER
    OUTPUT_STRIP_TRAILING_WHITESPACE
    WORKING_DIRECTORY ${CMAKE_SOURCE_DIR}
    )

message(STATUS "Build number: ${GIT_BUILD_NUMBER}")

file(WRITE "build_number.h" "#define GIT_BUILD_NUMBER \"${GIT_BUILD_NUMBER}\"")
