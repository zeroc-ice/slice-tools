# Copyright (c) ZeroC, Inc.

# Formats a copy of the file UNFORMATTED with the executable ICEFMT, and fails unless the result is the file
# FORMATTED. OUTPUT is where the copy goes.

file(COPY_FILE "${UNFORMATTED}" "${OUTPUT}")
execute_process(COMMAND "${ICEFMT}" "${OUTPUT}" RESULT_VARIABLE status)
if(NOT status EQUAL 0)
    message(FATAL_ERROR "icefmt failed: ${status}")
endif()

execute_process(COMMAND "${CMAKE_COMMAND}" -E compare_files "${OUTPUT}" "${FORMATTED}" RESULT_VARIABLE different)
if(different)
    file(READ "${OUTPUT}" output)
    message(FATAL_ERROR "${OUTPUT} is not ${FORMATTED}:\n${output}")
endif()
