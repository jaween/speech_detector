import 'dart:async';
import 'dart:typed_data';

import 'package:speech_detector/src/fvad.dart';
import 'package:speech_detector/src/util.dart';

/// Determines if audio contains speech using Voice Activity Detection (VAD).
///
/// VAD is implemented by libfvad: https://github.com/dpirch/libfvad/.
class SpeechDetector {
  final Fvad _fvad;
  final int _sampleRate;
  final int _bitsPerSample;
  final int _channelCount;
  final _speechController = StreamController<bool>();
  final _unusedSamples = <int>[];

  /// Creates a [SpeechDetector]. Call [dispose] when it's no longer needed.
  ///
  /// The implementation converts audio to signed 16-bit 8kHz mono format.
  /// All other audio formats will be resampled.
  ///
  /// These settings can only be changed by creating a new speech detector.
  factory SpeechDetector.create({
    int sampleRate = 44100,
    int bitsPerSample = 16,
    int channelCount = 2,
    Bar bar = Bar.highest,
  }) {
    return SpeechDetector._(
      sampleRate: sampleRate,
      bitsPerSample: bitsPerSample,
      channelCount: channelCount,
      bar: bar,
    );
  }

  SpeechDetector._({
    required int sampleRate,
    required int bitsPerSample,
    required int channelCount,
    required Bar bar,
  })  : _sampleRate = sampleRate,
        _bitsPerSample = bitsPerSample,
        _channelCount = channelCount,
        _fvad = Fvad()..setMode(bar.mode);

  /// Continuous speech detection, returns true on recently detected speech.
  bool append(Uint8List frame) {
    final correctFormat =
        (_sampleRate == 8000 || _sampleRate == 16000 || _sampleRate == 24000) &&
            _bitsPerSample == 16 &&
            _channelCount == 1;
    final Uint8List output;
    if (correctFormat) {
      output = frame;
    } else {
      output = resampleTo16Bit8000HzMono(
        frame,
        inputSampleRate: _sampleRate,
        bitsPerSample: _bitsPerSample,
        channelCount: _channelCount,
      );
    }

    final samples = Int16List.fromList([
      ..._unusedSamples,
      ...convertToInt16List(output),
    ]);
    _unusedSamples.clear();

    const chunkSize = 80;
    final chunkCount = samples.length ~/ chunkSize;

    bool? result = false;
    for (var i = 0; i < chunkCount; i++) {
      final chunk = samples.sublist(i * chunkSize, i * chunkSize + chunkSize);
      result = _fvad.process(chunk);
    }
    _unusedSamples.addAll(samples.sublist(chunkCount * chunkSize));
    if (result == null) {
      throw ArgumentError(
          'libfvad reported an invalid frame length, this is an error in package:speech_detector');
    }

    _speechController.add(result);
    return result;
  }

  /// Stream of results obtained from [append].
  Stream<bool> get stream => _speechController.stream;

  /// Frees up resources. This instance should not be used after this call.
  void dispose() {
    _fvad.dispose();
    _speechController.close();
  }
}

enum Bar {
  low(FvadMode.quality),
  medium(FvadMode.lowBitrate),
  high(FvadMode.aggressive),
  highest(FvadMode.veryAggressive);

  const Bar(this.mode);
  final FvadMode mode;
}
