# Copyright (c) ZeroC, Inc.

cmake_minimum_required(VERSION 3.24)

# The oldest macOS the executable runs on.
set(CMAKE_OSX_DEPLOYMENT_TARGET 11.0 CACHE STRING "")

project(icefmt VERSION 0.1.0 LANGUAGES CXX)

add_executable(icefmt
    src/Formatter.cpp
    src/Layout.cpp
    src/Main.cpp
    src/SyntaxParser.cpp
    src/SyntaxScanner.cpp)

target_compile_features(icefmt PRIVATE cxx_std_20)
set_target_properties(icefmt PROPERTIES CXX_EXTENSIONS OFF)
target_compile_definitions(icefmt PRIVATE ICEFMT_VERSION="${PROJECT_VERSION}")

if(MSVC)
    target_compile_options(icefmt PRIVATE /W4)
    # The executable runs without the Visual C++ redistributable.
    set_target_properties(icefmt PROPERTIES MSVC_RUNTIME_LIBRARY "MultiThreaded$<$<CONFIG:Debug>:Debug>")
else()
    target_compile_options(icefmt PRIVATE -Wall -Wextra -Wshadow -Wconversion -Wsign-conversion -Wpedantic)
endif()

if(MINGW)
    # MinGW calls wmain only when the executable is linked with its Unicode startup code.
    target_link_options(icefmt PRIVATE -municode)
endif()

if(CMAKE_SYSTEM_NAME STREQUAL "Linux")
    # The executable runs on any distribution, whatever its C and C++ libraries.
    target_link_options(icefmt PRIVATE -static)
endif()

enable_testing()

set(tests "${CMAKE_CURRENT_SOURCE_DIR}/tests")
set(output "${CMAKE_CURRENT_BINARY_DIR}/tests")
file(MAKE_DIRECTORY "${output}")

# Each case is a file in tests/unformatted, and the file icefmt makes of it in tests/formatted.
foreach(case comments crlf definitions ice37 ignore metadata operations)
    add_test(NAME format-${case} COMMAND "${CMAKE_COMMAND}"
        -DICEFMT=$<TARGET_FILE:icefmt>
        -DUNFORMATTED=${tests}/unformatted/${case}.ice
        -DFORMATTED=${tests}/formatted/${case}.ice
        -DOUTPUT=${output}/${case}.ice
        -P "${tests}/FormatTest.cmake")

    # --check lists a file that formatting would change, fails, and writes nothing.
    add_test(NAME check-${case} COMMAND "${CMAKE_COMMAND}"
        -DICEFMT=$<TARGET_FILE:icefmt>
        -DUNFORMATTED=${tests}/unformatted/${case}.ice
        -DOUTPUT=${output}/check-${case}.ice
        -P "${tests}/CheckTest.cmake")

    # A formatted file is left as it is.
    add_test(NAME keep-${case} COMMAND icefmt --check "${tests}/formatted/${case}.ice")
endforeach()

# A file with the comment "// icefmt: ignore-file" is left as it is.
add_test(NAME ignore-file COMMAND icefmt --check "${tests}/ignore-file.ice")

# Blanks after the backslash that ends a "//" comment are refused: without them, the preprocessor joins the next line
# to the comment. The file is made here because its line ends with blanks.
file(WRITE "${output}/backslash.ice"
    "module Demo\n{\n    struct A { int x; } // note \\  \n    struct B { int y; }\n}\n")
add_test(NAME backslash COMMAND icefmt --check "${output}/backslash.ice")
set_tests_properties(backslash PROPERTIES
    PASS_REGULAR_EXPRESSION "backslash\\.ice:3: blanks after the backslash that ends the line")

# On Windows, a file name can hold characters that the code page of the process doesn't have.
add_test(NAME format-wide-name COMMAND "${CMAKE_COMMAND}"
    -DICEFMT=$<TARGET_FILE:icefmt>
    -DUNFORMATTED=${tests}/unformatted/definitions.ice
    -DFORMATTED=${tests}/formatted/definitions.ice
    -DOUTPUT=${output}/定義.ice
    -P "${tests}/FormatTest.cmake")

# Given a directory, icefmt formats all the .ice files in that directory, recursively. It skips the files and
# directories whose name starts with a dot, and node_modules directories. The test creates its directory here because
# the repository ignores node_modules.
set(directory "${output}/directory")
file(WRITE "${directory}/nested/found.ice" "module  Demo {}\n")
file(WRITE "${directory}/nested/skipped.txt" "module  Demo {}\n")
file(WRITE "${directory}/nested/説明.txt" "module  Demo {}\n")
file(WRITE "${directory}/.hidden/skipped.ice" "module  Demo {}\n")
file(WRITE "${directory}/node_modules/skipped.ice" "module  Demo {}\n")
add_test(NAME directory COMMAND icefmt --check "${directory}")
set_tests_properties(directory PROPERTIES
    PASS_REGULAR_EXPRESSION "found\\.ice"
    FAIL_REGULAR_EXPRESSION "skipped\\.")
