cmake_minimum_required(VERSION 3.10)

project(fvad_library VERSION 0.0.1 LANGUAGES C)

include_directories(libfvad/include)

add_library(vad SHARED
  libfvad/src/signal_processing/division_operations.c
  libfvad/src/signal_processing/energy.c
  libfvad/src/signal_processing/get_scaling_square.c
  libfvad/src/signal_processing/resample_48khz.c
  libfvad/src/signal_processing/resample_by_2_internal.c
  libfvad/src/signal_processing/resample_fractional.c
  libfvad/src/signal_processing/spl_inl.c
  libfvad/src/vad/vad_core.c
  libfvad/src/vad/vad_filterbank.c
  libfvad/src/vad/vad_gmm.c
  libfvad/src/vad/vad_sp.c
  libfvad/src/fvad.c
)

set_target_properties(fvad PROPERTIES
  PUBLIC_HEADER libfvad/include/fvad.h
  OUTPUT_NAME "libfvad"
)

if (WIN32)
set_target_properties(fvad PROPERTIES
  WINDOWS_EXPORT_ALL_SYMBOLS ON
)
endif (WIN32)

target_compile_definitions(fvad PUBLIC DART_SHARED_LIB)
