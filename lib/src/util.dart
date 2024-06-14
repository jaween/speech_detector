import 'dart:math';
import 'dart:typed_data';

Uint8List resampleTo16Bit8000HzMono(
  Uint8List data, {
  required int inputSampleRate,
  required int bitsPerSample,
  required int channelCount,
}) {
  const targetSampleRate = 8000;
  final conversionRatio = inputSampleRate / targetSampleRate;
  final bytesPerSample = bitsPerSample ~/ 8;
  final numSamples = data.length ~/ (bytesPerSample * channelCount);
  final numOutputSamples = (numSamples / conversionRatio).ceil();
  final outputData = Uint8List(numOutputSamples * bytesPerSample);

  for (int i = 0; i < numOutputSamples; i++) {
    final inputSampleIndexDouble = i * conversionRatio;
    final inputSampleIndex = inputSampleIndexDouble.floor();
    final fraction = inputSampleIndexDouble - inputSampleIndex;

    // Linear interpolation for each sample, and averaged over the channels
    for (int byte = 0; byte < bytesPerSample; byte++) {
      int value = 0;
      for (int channel = 0; channel < channelCount; channel++) {
        final index1 =
            (inputSampleIndex * channelCount + channel) * bytesPerSample + byte;
        final index2 =
            min(index1 + bytesPerSample, data.length - bytesPerSample);

        if (index1 >= 0 && index2 < data.length) {
          final value1 = data[index1];
          final value2 = data[index2];
          value += ((1 - fraction) * value1 + fraction * value2).round();
        } else {
          value += data[index1];
        }
      }

      value ~/= channelCount;
      outputData[i * bytesPerSample + byte] = value.clamp(0, 255);
    }
  }

  return outputData;
}

Int16List convertToInt16List(Uint8List data) {
  final newSize = data.length ~/ 2;
  final byteData = data.buffer.asByteData();
  final int16List = Int16List(newSize);
  for (var i = 0; i < newSize; i++) {
    final value = byteData.getInt16(i * 2, Endian.little);
    int16List.buffer.asByteData().setInt16(i * 2, value, Endian.big);
  }
  return int16List;
}
