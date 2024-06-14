import 'dart:ffi';
import 'dart:io' show Platform;
import 'dart:typed_data';

import 'package:ffi/ffi.dart' as ffi;

import 'fvad_bindings_generated.dart' as bindings;

final DynamicLibrary _dylib = () {
  if (Platform.isMacOS || Platform.isIOS) {
    const libName = 'speech_detector';
    return DynamicLibrary.open('$libName.framework/$libName');
  } else {
    const libName = 'fvad';
    if (Platform.isAndroid || Platform.isLinux) {
      return DynamicLibrary.open('lib$libName.so');
    }
    if (Platform.isWindows) {
      return DynamicLibrary.open('$libName.dll');
    }
    throw UnsupportedError('Unknown platform: ${Platform.operatingSystem}');
  }
}();

final _bindings = bindings.FvadBindings(_dylib);

// Access to libfvad.
class Fvad {
  late final Pointer<bindings.Fvad> _fvad;

  Fvad() {
    _fvad = _bindings.fvad_new();
  }

  /// Clears the state, mode and sample rate back to default.
  void reset() => _bindings.fvad_reset(_fvad);

  /// Changes the VAD operating aggressiveness.
  void setMode(FvadMode mode) => _bindings.fvad_set_mode(_fvad, mode.value);

  /// Sets the input sample rate in Hz for a VAD instance.
  void setSampleRate(FvadSampleRate sampleRate) =>
      _bindings.fvad_set_sample_rate(_fvad, sampleRate.value);

  /// Calculates a VAD decision for an audio frame.
  bool? process(Int16List frame) {
    final framePointer =
        ffi.malloc.allocate<Int16>(frame.length * sizeOf<Int16>());
    for (var i = 0; i < frame.length; i++) {
      framePointer[i] = frame[i];
    }

    final result = _bindings.fvad_process(_fvad, framePointer, frame.length);
    return result == 1
        ? true
        : result == 0
            ? false
            : null;
  }

  /// Frees up the resources used by the libfvad instance.
  void dispose() {
    _bindings.fvad_free(_fvad);
    _fvad = nullptr;
  }
}

enum FvadSampleRate {
  rate8000(8000),
  rate16000(16000),
  rate32000(32000),
  rate48000(48000);

  const FvadSampleRate(this.value);

  final int value;
}

enum FvadMode {
  quality(0),
  lowBitrate(1),
  aggressive(2),
  veryAggressive(3);

  const FvadMode(this.value);

  final int value;
}
