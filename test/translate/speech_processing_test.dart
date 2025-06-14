import 'dart:async';

import 'package:flutter_test/flutter_test.dart';
import 'package:hands_talks/translate/speechToSign/speech_processing_logic.dart';
import 'package:mockito/mockito.dart';

import 'speech_processing_logic_test.mocks.dart';

void main() {
  late SpeechProcessingLogic logic;
  late MockSpeechToText mockSpeech;

  setUp(() {
    mockSpeech = MockSpeechToText();
    logic = SpeechProcessingLogic(speechToText: mockSpeech); // inject the mock
  });

  group(
    "SpeechProcessingLogic",
    () {
      test('listen() starts speech recognition when available', () async {
        when(mockSpeech.initialize(
          onStatus: anyNamed('onStatus'),
          onError: anyNamed('onError'),
        )).thenAnswer((_) async => true);
        when(mockSpeech.listen(
          onResult: anyNamed('onResult'),
          localeId: anyNamed('localeId'),
        )).thenAnswer((_) async {});

        await logic.listen();

        expect(logic.isRecording, true);

        verify(mockSpeech.listen(
          localeId: anyNamed('localeId'),
          onResult: anyNamed('onResult'),
        )).called(1);
      });

      test(
          'restartListening() calls listen() if not listening and isRecording = true',
          () async {
        logic.isRecording = true;

        when(mockSpeech.isListening).thenReturn(false);

        when(mockSpeech.initialize(
          onStatus: anyNamed('onStatus'),
          onError: anyNamed('onError'),
        )).thenAnswer((_) async => true);

        when(mockSpeech.listen(
          localeId: anyNamed('localeId'),
          onResult: anyNamed('onResult'),
        )).thenAnswer((_) async {
          return Future.value(); // Ensures Future<void>
        });

        await logic.restartListening();

        verify(mockSpeech.listen(
          localeId: anyNamed('localeId'),
          onResult: anyNamed('onResult'),
        )).called(1);
      });

      test(
          'stopRecording() stops speech, cancels timers, and sets isRecording = false',
          () async {
        logic.timer = Timer(Duration(seconds: 1), () {});
        logic.waveformTimer = Timer(Duration(seconds: 1), () {});
        logic.isRecording = true;

        when(mockSpeech.stop()).thenAnswer((_) async => Future.value());

        await logic.stopRecording();

        expect(logic.isRecording, false);
        expect(logic.timer?.isActive ?? false, false);
        expect(logic.waveformTimer?.isActive ?? false, false);
      });

      test('deleteRecording() resets state and clears waveform and words',
          () async {
        logic.lastWords = ['test'];
        logic.waveformValues = [0.5];
        logic.waveformValuesLine = [0.3];
        logic.elapsedSeconds = 10;
        logic.isRecording = true;

        logic.timer = Timer(Duration(seconds: 1), () {});
        logic.waveformTimer = Timer(Duration(seconds: 1), () {});

        when(mockSpeech.stop()).thenAnswer((_) async => Future.value());

        await logic.deleteRecording();

        expect(logic.isRecording, false);
        expect(logic.lastWords.isEmpty, true);
        expect(logic.waveformValues.every((v) => v == 0), true);
        expect(logic.waveformValuesLine.every((v) => v == 0), true);
        expect(logic.elapsedSeconds, 0);
      });
    },
  );
}
