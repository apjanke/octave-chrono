cmake_minimum_required(VERSION 3.13)
project(octave_chrono)

set(CMAKE_CXX_STANDARD 14)

include_directories(src)
include_directories(/usr/local/include/octave-4.4.1)

add_executable(octave_chrono
        src/__oct_time_binsearch__.cc)
