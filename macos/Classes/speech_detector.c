// Relative import to be able to reuse the C sources.
// See the comment in ../{projectName}}.podspec for more information.
#include "../../src/libfvad/src/signal_processing/division_operations.c"
#include "../../src/libfvad/src/signal_processing/energy.c"
#include "../../src/libfvad/src/signal_processing/get_scaling_square.c"
#include "../../src/libfvad/src/signal_processing/resample_48khz.c"
#include "../../src/libfvad/src/signal_processing/resample_by_2_internal.c"
#include "../../src/libfvad/src/signal_processing/resample_fractional.c"
#include "../../src/libfvad/src/signal_processing/spl_inl.c"
#include "../../src/libfvad/src/vad/vad_core.c"
#include "../../src/libfvad/src/vad/vad_filterbank.c"
#include "../../src/libfvad/src/vad/vad_gmm.c"
#include "../../src/libfvad/src/vad/vad_sp.c"
#include "../../src/libfvad/src/fvad.c"