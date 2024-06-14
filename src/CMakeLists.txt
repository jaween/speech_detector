# The Flutter tooling requires that developers have CMake 3.10 or later
# installed. You should not increase this version, as doing so will cause
# the plugin to fail to compile for some customers of the plugin.
cmake_minimum_required(VERSION 3.10)

project(speech_detector_library VERSION 0.0.1 LANGUAGES C)

add_library(speech_detector SHARED
  "speech_detector.c"
)

set_target_properties(speech_detector PROPERTIES
  PUBLIC_HEADER speech_detector.h
  OUTPUT_NAME "speech_detector"
)

target_compile_definitions(speech_detector PUBLIC DART_SHARED_LIB)
