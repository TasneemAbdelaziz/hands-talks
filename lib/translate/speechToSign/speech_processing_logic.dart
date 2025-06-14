import 'dart:async';
import 'dart:math';

import 'package:flutter/material.dart';
import 'package:speech_to_text/speech_to_text.dart' as stt;
import 'package:speech_to_text/speech_to_text.dart';

class SpeechProcessingLogic extends ChangeNotifier {
  bool isRecording = false;
  List<double> waveformValues = List.generate(50, (index) => 0);
  List<double> waveformValuesLine = List.generate(50, (index) => 0);
  Timer? timer;
  int elapsedSeconds = 0;
  Timer? waveformTimer;
  late stt.SpeechToText speech = stt.SpeechToText();
  List<String> lastWords = [];
  SpeechProcessingLogic({SpeechToText? speechToText}) {
    speech = speechToText ?? SpeechToText();
  }

  listen() async {
    bool available = await speech.initialize(
      onStatus: (val) {
        print('onStatus: $val');
        if (val == "done" || val == "notListening") {
          restartListening();
          notifyListeners();
        }
      },
      onError: (val) {
        print('onError: $val');
        CircularProgressIndicator();
        restartListening();
      },
    );

    if (available) {
      isRecording = true;
      speech.listen(
          localeId: 'ar', // Arabic language
          onResult: (val) {
            if (val.finalResult) {
              lastWords.add(val.recognizedWords);
            }
            notifyListeners();
          });
    }
  }

  restartListening() {
    if (!speech.isListening && isRecording == true) {
      debugPrint("Restarting listening...");
      listen();
      notifyListeners();
    }
  }

  void startWaveformAnimation() {
    waveformTimer = Timer.periodic(Duration(milliseconds: 300), (timer) {
      waveformValues = List.generate(10, (index) => Random().nextDouble());
      waveformValuesLine = List.generate(50, (index) => Random().nextDouble());
    });
    notifyListeners();
  }

  ///stop recording
  Future<void> stopRecording() async {
    await speech.stop();
    isRecording = false;
    timer!.cancel();
    waveformTimer?.cancel();
    notifyListeners();
  }

  /// Delete recording
  Future<void> deleteRecording() async {
    await stopRecording();

    waveformValues = [];
    elapsedSeconds = 0;
    lastWords = []; // Clear recognized words
    waveformTimer?.cancel();
    waveformValues = List.generate(10, (index) => 0); // Reset waveform
    waveformValuesLine = List.generate(50, (index) => 0); // Reset waveform
    notifyListeners();
  }
}




